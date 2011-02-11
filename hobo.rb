#!/usr/bin/env ruby
require 'httparty'
require 'builder'
require 'optparse'
require 'chronic'  # gem install aaronh-chronic for Ruby 1.9 compatibility

module Hobo
  extend self
  include HTTParty
  base_uri 'http://nagging-hobo.heroku.com'
  #base_uri 'http://localhost:1234'
  format :xml
  debug_output $stdout

  def post_job(details)
    builder = Builder::XmlMarkup.new
    post_data = { :body => builder.job { |j|
      j.name       details[:title]
      j.message    details[:msg]
      j.email      details[:email]
      j.trigger_at details[:time]
    }}
    puts post("/jobs", post_data)
  end
end


options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: hobo.rb [options]"
  opts.on("-t", "--title TITLE", String, "Title of your push message") do |title|
    options[:title] = title
  end
  opts.on("-m", "--message MESSAGE", String, "Push Message") do |msg|
    options[:msg] = msg
  end
  opts.on("-e", "--email ADDRESS", String, "Email address of your boxcar account") do |email|
    options[:email] = email
  end
  opts.on("-w", "--when TIME", String, "Push message at given time") do |time|
    options[:time] = Chronic.parse(time)
  end
end.parse!

[:title, :msg, :email, :time].each do |param|
  unless options[param]
    raise ArgumentError, "#{param} parameter is required, use -h for help"
  end
end

Hobo.post_job(options)
