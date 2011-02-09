require 'sinatra'
require 'nokogiri'
require 'dm-core'
require 'dm-validations'
require 'dm-migrations'
require 'httparty'

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite3:hobo.db')

MOMENT_API_KEY = ENV['MOMENT_API_KEY']
BOXCAR_API_KEY = ENV['BOXCAR_API_KEY']

module NaggingHobo
  extend self 
  
  def content(xml_node)
    nil_or_block(xml_node) { |node| node.content }
  end
  
  def nil_or_block(value)
    unless value.nil?
      yield value
    end
  end
  
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

    validates_presence_of :trigger_at, :name
    
    def self.create_from_xml(xml)
      doc = Nokogiri::XML(xml)
      Job.create( 
        :name => NaggingHobo::content(doc.at('name')), 
        :trigger_at => NaggingHobo::content(doc.at('trigger_at')),
        :message => NaggingHobo::content(doc.at('message')),
        :email => Digest::MD5.hexdigest(NaggingHobo::content(doc.at('email'))) )
    end
    
  end
  
  class Boxcar
    include HTTParty
    base_uri "http://boxcar.io"
  end
  
  class Moment
    include HTTParty
    base_uri 'https://moment.heroku.com'
    format :json
    # debug_output $stdout
  end
  
  class Application < Sinatra::Base

    post '/jobs' do
      @job = Job.create_from_xml( request.body.read )
      options = { :query => { 
        :apikey => MOMENT_API_KEY,
        :job => {
          :at => @job.trigger_at.strftime(fmt='%FT%T%z'),
          :method => "GET",
          :uri => "http://nagging-hobo.heroku.com/jobs/#{@job.id}/trigger"
        }}}
      result = Moment.post("/jobs.json", options)
      if result['success']
        @job.moment_id = result['success']['job']['id']
        @job.save
      end
      @job.inspect
    end

    get '/jobs/:id/trigger' do
      @job = Job.get(params[:id])
   
      options = { :body => { 
        :email => @job.email,
        :notification => {
          :from_screen_name => @job.name,
          :message => @job.message
        }}}
      
      Boxcar.post("/devices/providers/#{BOXCAR_API_KEY}/notifications", options)
      
      @job.complete = true
      @job.save
            
      puts "Job #{@job.name} triggered!"
    end
  end
end

DataMapper.finalize
DataMapper.auto_upgrade!