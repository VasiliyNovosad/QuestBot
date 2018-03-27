require './lib/reply_markup_formatter'
require './lib/app_configurator'

class MessageSender
  attr_reader :bot
  attr_reader :text
  attr_reader :chat
  attr_reader :answers
  attr_reader :logger
  attr_reader :latitude
  attr_reader :longitude

  def initialize(options)
    @bot = options[:bot]
    @text = options[:text]
    @chat = options[:chat]
    @answers = options[:answers]
    @latitude = options[:latitude]
    @longitude = options[:longitude]
    @name = options[:name]
    @logger = AppConfigurator.new.get_logger
  end

  def send
    if reply_markup
      bot.api.send_message(chat_id: chat.id, text: text,
                           parse_mode: 'Markdown', reply_markup: reply_markup)
    else
      bot.api.send_message(chat_id: chat.id, text: text, parse_mode: 'Markdown')
    end

    # logger.debug "sending '#{text}' to #{chat.username}"
  end

  def send_photo
    bot.api.send_photo(chat_id: chat.id, photo: Faraday::UploadIO.new(File.dirname(__FILE__) + text, 'image/jpeg'))
  end

  def send_document
    logger.debug text
    bot.api.send_document(chat_id: chat.id, document: Faraday::UploadIO.new(File.dirname(__FILE__) + text, 'text/xml'))
  end

  def send_location
    bot.api.send_location(chat_id: chat.id, latitude: latitude, longitude: longitude)
  end

  private

  def reply_markup
    ReplyMarkupFormatter.new(answers).get_markup if answers
  end
end
