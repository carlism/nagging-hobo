require 'sinatra'
require 'nokogiri'
require 'dm-core'
require 'dm-validations'
require 'dm-migrations'
require 'net/http'
require 'net/https'

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite3://my.db')

MOMENT_API_KEY = ENV['MOMENT_API_KEY']

module NaggingHobo
  extend self
  
  class Job
    include DataMapper::Resource
    property :id,         Integer, :serial=>true
    property :name,       String
    property :created_at, DateTime
    property :trigger_at, DateTime    
    property :complete,   Boolean, :default=>false

    validates_present :trigger_at, :name
  end
  
  class Application < Sinatra::Base
    # Make sure our template can use <%=h
    helpers do
      include Rack::Utils
      alias_method :h, :escape_html
    end

    post '/jobs' do
      doc = Nokogiri::XML(request.body.read)
      @job = Job.create( :name => doc.at('name'), :trigger_at => doc.at('trigger_at') )
      req = Net::HTTP::Post.new("jobs.json")
      req.use_ssl = true      
      req.set_form_data({'job[at]' => job.trigger_at, 'job[method]'=>'PUT', 
        "job[uri]" => "http://nagging-hobo.heroku.com/jobs/#{job.id}/trigger",
        "apikey" => MOMENT_API_KEY }, ';')
      res = Net::HTTP.new("momentapp.com").start {|http| http.request(req) }
      case res
        when Net::HTTPSuccess, Net::HTTPRedirection
          puts "Success!"
        else
          puts res.error!
        end
      end
    end

    put '/jobs/:id/trigger' do
      @job = Job.get(params[:id])
      @job.complete = true
      @job.save
      puts "Job #{@job.name} triggered!"
    end
    
    get '/test' do
      # content_type 'text/html'
      # headers 'Cache-Control' => "public, max-age=600"
      erb :test
    end
  end
end

DataMapper.finalize
DataMapper.auto_upgrade!