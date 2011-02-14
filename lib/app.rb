require 'sinatra'
require 'models'
require 'erb'

module NaggingHobo
  class Application < Sinatra::Base
    helpers do
      include Rack::Utils
      alias_method :h, :escape_html
    end

    post '/jobs' do
      content_type :xml
      begin
        @job = Model::Job.schedule( request.body.read )
        [200, @job.to_xml]
      rescue Exception => err
        [500, erb(:error, :locals => { :error => err })]
      end
    end

    get '/jobs/:id/trigger' do
      content_type :xml
      begin
        @job = Model::Job.trigger(params[:id])
        [200, "<success/>"]
      rescue Exception => err
        [500, erb(:error, :locals => { :error => err })]
      end
    end
  end
end
