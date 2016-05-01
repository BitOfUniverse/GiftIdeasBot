require 'telegram/bot'

require './lib/message_responder'
require './lib/app_configurator'

class BotServer
  attr_reader :bot, :config

  def initialize
    configure
    setup_bot
  end

  def call(env)
    request = Rack::Request.new env
    if request.post?
      json = JSON::parse(request.body.read)
      process_update(json)
      ['200', {'Content-Type' => 'text/json'}, ['']]
    else
      ['200', {'Content-Type' => 'text/json'}, ['Hey! I\'m telegram bot server!']]
    end
  end

  def logger
    config.get_logger
  end

  def bot_token
    config.get_token
  end

  def bot_webhook_url
    URI::join(config.get_bot_webhook_url, bot_token).to_s
  end

  def process_update(data)
    update = Telegram::Bot::Types::Update.new(data)
    message = extract_message(update)
    MessageResponder.new(bot: bot, message: message).respond
  end

  private

  def configure
    @config ||= AppConfigurator.new
    config.configure
  end

  def setup_bot
    @bot = Telegram::Bot::Client.new(bot_token, logger: logger)
    @bot.api.setWebhook(url: bot_webhook_url)
  end

  def extract_message(update)
    update.inline_query || update.chosen_inline_result || update.message
  end
end

