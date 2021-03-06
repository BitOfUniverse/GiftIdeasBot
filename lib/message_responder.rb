require './models/user'
require './lib/message_sender'
require 'httparty'

class MessageResponder
  attr_reader :message
  attr_reader :bot
  attr_reader :user
  attr_reader :logger
  attr_reader :bot_username

  def initialize(options)
    @bot          = options[:bot]
    @message      = options[:message]
    @user         = User.where(uid: message.from.id).first_or_create
    @logger       = AppConfigurator.new.get_logger
    @bot_username = AppConfigurator.new.get_bot_name
  end

  def respond
    logger.debug "received '#{message.inspect}'"

    text = case parse_command(message.text)
             when '/start'
               greeting_message
             when '/stop'
               farewell_message
             when '/idea', 'идея'
               collect_ideas(1)
             when '/5ideas', '5 идей'
               collect_ideas(5)
             when '/10ideas', '10 идей'
               collect_ideas(10)
             else
               message.text # echo
           end

    answer_with_text text
  end

  private

  def parse_command(text)
    text.split(bot_username).last.strip
  end

  def collect_ideas(num)
    ideas = load_ideas(num)

    ideas.map do |idea|
      idea['title']
    end.join("\r\n")
  end

  def load_ideas(num)
    api = 'https://ideasforgifts.herokuapp.com/api/ideas'

    url         = "#{api}?offset=#{user.offset}"
    response    = HTTParty.get(url)
    user.offset += num
    user.save

    # TODO: reset user offset if limit is reached
    response.parsed_response['records'][0, num]
  end

  def answer_with_text(text)
    MessageSender.new(bot: bot, chat: message.chat, text: text).send
  end

  def greeting_message
    %q{Привет! У меня есть огромное количество идей подарков!
    /idea
    /5ideas
    /10ideas
    }
  end

  def farewell_message
    I18n.t('farewell_message')
  end
end
