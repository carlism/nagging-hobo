require 'dm-core'
require 'dm-validations'
require 'dm-migrations'
require 'nokogiri'
require 'config'

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
      property :created_at, DateTime, :default=> lambda{|res,prop| DateTime.now }
      property :trigger_at, DateTime
      property :complete,   Boolean, :default=>false

      validates_presence_of :trigger_at, :name, :email

      def self.create_from_xml(xml)
        doc = Nokogiri::XML(xml)
        Job.create(
          :name => Model::content(doc.at('name')),
          :trigger_at => Model::content(doc.at('trigger_at')),
          :message => Model::content(doc.at('message')),
          :email => Digest::MD5.hexdigest(Model::content(doc.at('email'))) )
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
