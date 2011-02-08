require 'sinatra'

module NaggingHobo
  class Application < Sinatra::Base
    # Make sure our template can use <%=h
    helpers do
      include Rack::Utils
      alias_method :h, :escape_html
    end

    get '/test' do
      # content_type 'text/html'
      # headers 'Cache-Control' => "public, max-age=600"
      erb :test
    end
  end
end