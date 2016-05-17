require 'active_record'
require 'logger'

class DatabaseConnector
  class << self
    def establish_connection
      ActiveRecord::Base.logger = Logger.new(active_record_logger_path)

      ActiveRecord::Base.establish_connection(configuration)
    end

    def configuration
      if ENV['DATABASE_URL']
        require 'uri'

        uri = URI(ENV['DATABASE_URL'])
        {
          'adapter'  => uri.scheme == "postgres" ? "postgresql" : uri.scheme,
          'database' => (uri.path || "").split("/")[1],
          'user'     => uri.user,
          'password' => uri.password,
          'host'     => uri.host,
          'port'     => uri.port
        }
      else
        YAML::load(File.open('config/database.yml'))
      end
    end

    private

    def active_record_logger_path
      'debug.log'
    end

    def database_config_path
      'config/database.yml'
    end
  end
end
