$LOAD_PATH.unshift File.expand_path('lib', File.dirname(__FILE__))

require 'rspec'
require 'sinatra'

require 'config'

set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false

module SpecHelper
  def load_fixture(filename)
    File.read(File.expand_path('../fixtures/' + filename, __FILE__))
  end

end

RSpec.configure do |conf|
  conf.include SpecHelper
end