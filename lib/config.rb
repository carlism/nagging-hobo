module NaggingHobo
  module Config
    MOMENT_API_KEY = ENV['MOMENT_API_KEY'] || "Your API Key"
    MOMENT_API_URI = "https://moment.heroku.com"
    #MOMENT_API_URI = "https://momentapp.com"

    BOXCAR_API_KEY = ENV['BOXCAR_API_KEY'] || "Your API Key"
    BOXCAR_API_URI = "http://boxcar.io"

    # This is the host name used for the callback from Moment.
    # Basically it's the public url where the app is deployed
    # so Moment can send notifications.
    DEPLOY_URI = "http://nagging-hobo.heroku.com"
    DB_URL = ENV['DATABASE_URL'] || 'sqlite3:hobo.db'
  end
end
