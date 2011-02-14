require 'dm-core'
require 'dm-validations'
require 'dm-migrations'
require 'services'
require 'nokogiri'
require 'config'
require 'builder'

DataMapper.setup(:default, NaggingHobo::Config::DB_URL)

module NaggingHobo
  module Model
    extend self

    class Job
      include DataMapper::Resource
      property :id,         Serial
      property :moment_id,  String
      property :name,       String
      property :message,    String
      property :email,      String
      property :created_at, DateTime, :default=>lambda{|res,prop| DateTime.now}
      property :trigger_at, DateTime
      property :complete,   Boolean, :default=>false

      validates_presence_of :trigger_at, :name, :email

      def self.schedule(xml)
        @job = Model::Job.create_from_xml( xml )
        @job.moment_id = Service::Moment.schedule_job(@job)
        @job.save
        @job
      end

      def self.trigger(id)
        @job = Model::Job.get(id)
        Service::Boxcar.notify(@job)
        @job.complete = true
        @job.save
        @job
      end

      def self.create_from_xml(xml)
        doc = Nokogiri::XML(xml)
        Job.create(
          :name => Model.content(doc.at('name')),
          :trigger_at => Model.content(doc.at('trigger_at')),
          :message => Model.content(doc.at('message')),
          :email => Digest::MD5.hexdigest(Model.content(doc.at('email'))) )
      end

      def to_xml
        builder = Builder::XmlMarkup.new(:indent=>2)
        builder.job do |j|
          [:id, :moment_id, :name, :message,
           :email, :complete, :trigger_at].each do |attr|
            j.tag!(attr, send(attr))
          end
        end
      end
    end

    def content(xml_node)
      nil_or_block(xml_node) { |node| node.content }
    end

    def nil_or_block(value)
      unless value.nil?
        yield value
      end
    end

  end
end

DataMapper.finalize
DataMapper.auto_upgrade!
