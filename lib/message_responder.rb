require './lib/message_sender'
require './lib/quest_parser'
require './lib/app_configurator'

class MessageResponder
  attr_accessor :message
  attr_reader :bot
  attr_accessor :parser, :chat, :timer_interval, :start_timer

  def initialize(options)
    @bot = options[:bot]
    @message = options[:message]
    @timer_interval = 5
    @start_timer = false
    @chat = @message.chat
    @parser = nil
  end

  def respond

    on /^\/start$/ do
      answer_with_greeting_message
    end

    on /^\/stop$/ do
      @parser = nil
      @chat = nil
    end

    on /^\/start / do
      @parser = QuestParser.new(message.text[7..-1].strip, 'link')
      @chat = message.chat
    end

    on /^\/restart$/ do
      if parser
        url = parser.url
        login = parser.login
        password = parser.password
        @parser = nil
        @parser = QuestParser.new(url, 'link')
        @parser.login = login
        @parser.password = password
      end
    end

    on /^\.help$/ do
      text = "List of commands:
/start <game_link>
/stop
/restart
/starttimer
/starttimer <secs>
/stoptimer
/+
/*
/-
/. <answer1> <answer2> ... <answern>
/.<answer>  /,<answer>"
      answer_with_message(text)
    end

    on /^\/\+$/ do
      send_updated_level(chat || message.chat) if parser
    end

    on /^\/\+\+$/ do
      send_updated_level(message.chat) if parser
    end

    on /^\/parse$/ do
      send_updated_level(chat || message.chat) if parser
    end

    on /^\/-$/ do
      send_needed_sectors(chat || message.chat) if parser
    end

    on /^\/--$/ do
      send_needed_sectors(message.chat) if parser
    end

    on /^\/\*$/ do
      send_full_level(chat || message.chat) if parser
    end

    on /^\/\*\*$/ do
      send_full_level(message.chat) if parser
    end

    on /^\/(\.|,) / do
      if parser
        if parser.get_html_from_url
          message.text[3..-1].strip.split(' ').each do |code|
            parser.send_code(code)
          end
        else
          send_errors(chat || message.chat)
        end
      end
    end

    on /^\/(\.|,)/ do
      if parser
        if parser.get_html_from_url
          parser.send_code(message.text[2..-1].strip)
        else
          send_errors(chat || message.chat)
        end
      end
    end

    on /^\.setlogin / do
      parser.login = message.text[10..-1].strip if parser
    end

    on /^\.setpassword / do
      parser.password = message.text[13..-1].strip if parser
    end

    on /^\.setuser / do
      if parser
        parser.login = message.text[9..-1].strip
        parser.password = AppConfigurator.new.get_user(parser.login)
      end
    end

    on /^\/setchatcurrent$/ do
      @chat = message.chat
    end

    on /^\/stoptimer$/ do
      @start_timer = false
    end

    on /^\/starttimer / do
      @timer_interval = message.text[12..-1].strip.to_i
      @start_timer = true
    end

    on /^\/starttimer$/ do
      @timer_interval = 5
      @start_timer = true
    end

  end

  def send_message_by_timer
    if start_timer
      if parser
        if parser.get_html_from_url
          parser.parse_content(false)
          if chat && parser.question_texts_new.count > 0
            parser.question_texts_new.each do |mess|
              parser.question_texts.push(mess)
            end
            message_str = parser.question_texts_new.join("\n")
            if message_str.length < 4000
              answer_with_message message_str, chat
            else
              message_str.chars.each_slice(4000).map(&:join).each do |msg|
                answer_with_message msg, chat
              end
            end
            parser.question_texts_new = []
          end
        else
          send_errors(chat || message.chat)
        end
      end
    end
  end

  private

  def on regex, &block
    regex =~ message.text

    if $~
      case block.arity
      when 0
        yield
      when 1
        yield $1
      when 2
        yield $1, $2
      end
    end
  end

  def answer_with_greeting_message
    answer_with_message "Hello, #{message.from.first_name}", message.chat
  end

  def answer_with_farewell_message
    answer_with_message 'farewell_message', message.chat
  end

  def send_updated_level(chat)
    if parser.get_html_from_url
      parser.parse_content(true)
      updated_info = parser.question_texts_new
      if updated_info.count > 0
        updated_info.each do |mess|
          parser.question_texts.push(mess)
        end
        send_level_text(updated_info, chat)
        parser.question_texts_new = []
      end
    else
      send_errors(chat)
    end
  end

  def send_full_level(chat)
    if parser.get_html_from_url
      full_info = parser.parse_full_info
      send_level_text(full_info, chat) if full_info.count > 0
    else
      send_errors(chat)
    end
  end

  def send_needed_sectors(chat)
    if parser.get_html_from_url
      needed_sectors = parser.parse_needed_sectors
      text = "Осталось закрити:\n#{needed_sectors.join(', ')}"
      answer_with_message text, chat if needed_sectors.count > 0
    else
      send_errors(chat)
    end
  end

  def send_errors(chat)
    text = parser.errors
    answer_with_message text.join("\n"), chat if text.count > 0
    parser.errors = []
  end

  def send_level_text(text, chat)
    message_str = text.join("\n")
    if message_str.length < 4000
      answer_with_message message_str, chat
    else
      message_str.chars.each_slice(4000).map(&:join).each do |msg|
        answer_with_message msg, chat
      end
    end
  end

  def answer_with_message(text, chat)
    MessageSender.new(bot: bot, chat: chat, text: text).send
  end
end