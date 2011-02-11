require 'sinatra'
require 'models'
require 'services'
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
        @job = Model::Job.create_from_xml( request.body.read )
        @job.moment_id = Service::Moment.schedule_job(@job)
        @job.save
        [200, erb(:job)]
      rescue Exception => err
        [500, erb(:error, :locals => { :error => err })]
      end
    end

    get '/jobs/:id/trigger' do
      content_type :xml
      begin
        @job = Model::Job.get(params[:id])
        Service::Boxcar.notify(@job)
        @job.complete = true
        @job.save
        [200, erb(:success)]
      rescue Exception => err
        [500, erb(:error, :locals => { :error => err })]
      end
    end
  end
end
