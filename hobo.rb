#!/usr/bin/env ruby
require 'httparty'
require 'builder'
require 'optparse'
require 'chronic'  # gem install aaronh-chronic for Ruby 1.9 compatibility

class Hobo
  include HTTParty
  base_uri 'http://nagging-hobo.heroku.com'
  format :xml
  debug_output $stdout

  def self.post_job(details)
    builder = Builder::XmlMarkup.new
    post_data = { :body => builder.job { |j|
      j.name details[:title]
      j.message details[:msg]
      j.email details[:email]
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
raise ArgumentError, "title parameter required, see use -h for help" unless options[:title]
raise ArgumentError, "message parameter required, see use -h for help" unless options[:msg]
raise ArgumentError, "email parameter required, see use -h for help" unless options[:email]
raise ArgumentError, "when/time parameter required, see use -h for help" unless options[:time]

Hobo.post_job(options)