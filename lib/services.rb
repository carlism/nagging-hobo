require 'httparty'
require 'config'

module NaggingHobo
  module Service
    ServiceException = Class.new(StandardError)

    module Boxcar
      extend self
      include HTTParty
      base_uri NaggingHobo::Config::BOXCAR_API_URI
      
      def notify(job)
        options = { :body => {
          :email => job.email,
          :notification => {
            :from_screen_name => job.name,
            :message => job.message
          }}}
        post("/devices/providers/#{NaggingHobo::Config::BOXCAR_API_KEY}/notifications", options)
      end
    end

    module Moment
      extend self
      include HTTParty
      base_uri NaggingHobo::Config::MOMENT_API_URI
      format :json

      def schedule_job(job)
        options = { :query => {
          :apikey => NaggingHobo::Config::MOMENT_API_KEY,
          :job => {
            :at => job.trigger_at.strftime(fmt='%FT%T%z'),
            :method => "GET",
            :uri => "#{NaggingHobo::Config::DEPLOY_URI}/jobs/#{job.id}/trigger"
          }}}
        result = post("/jobs.json", options)
        return result['success']['job']['id'] if result['success']
        raise ServiceException, result['error'].keys.first['at']
      end
    end
  end
end
