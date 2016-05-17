require 'logger'

require './lib/database_connector'

class AppConfigurator
  attr_accessor :config

  def initialize
    load_config
  end

  def configure
    setup_i18n
    setup_database
  end

  def load_config
    config_file = 'config/secrets.yml'
    self.config = ENV.to_hash

    self.config.merge!(YAML::load(IO.read(config_file))) if File.exist?(config_file)
  end

  def get_token
    config['telegram_bot_token']
  end

  def get_bot_name
    config['telegram_bot_name']
  end

  def get_bot_webhook_url
    config['telegram_bot_webhook']
  end

  def get_logger
    Logger.new(STDOUT, Logger::DEBUG)
  end

  private

  def setup_i18n
    I18n.load_path = Dir['config/locales.yml']
    I18n.locale    = :en
    I18n.backend.load_translations
  end

  def setup_database
    DatabaseConnector.establish_connection
  end
end
