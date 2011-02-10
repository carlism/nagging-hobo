require 'httparty'
require 'builder'

class Hobo
  include HTTParty
  base_uri 'http://localhost:1234'
  format :xml
  debug_output $stdout

  def self.post_job
    builder = Builder::XmlMarkup.new
    options = { :body => builder.job { |j|
      j.name 'test name'
      j.message 'test message'
      j.email 'carl.leiby@gmail.com'
      j.trigger_at '2011-02-19T14:15:00-05:00'
    }}
    puts post("/jobs", options)
  end
end

Hobo.post_job