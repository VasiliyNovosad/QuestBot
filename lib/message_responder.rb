require './lib/message_sender'
require './lib/quest_parser'

class MessageResponder
  attr_reader :message
  attr_reader :bot
  attr_accessor :parser, :chat, :timer_interval, :start_timer

  def initialize(options)
    @bot = options[:bot]
    @message = options[:message]
  end

  def respond
    # on /^\/start/ do
    #   answer_with_greeting_message
    # end
    #
    # on /^\/stop/ do
    #   answer_with_farewell_message
    # end



    on /^\/start$/ do
      answer_with_greeting_message
    end

    on /^\/stop$/ do
      @parser = nil
      @chat = nil
    end

    on /^\/start / do
      @parser = QuestParser.new(message.text[7..-1].strip, 'link')
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
      send_updated_level(chat) if parser
    end

    on /^\/\+\+$/ do
      send_updated_level if parser
    end

    on /^\/parse$/ do
      send_updated_level(chat) if parser
    end

    on /^\/-$/ do
      send_needed_sectors(chat) if parser
    end

    on /^\/--$/ do
      send_needed_sectors if parser
    end

    on /^\/\*$/ do
      send_full_level(chat) if parser
    end

    on /^\/\*\*$/ do
      send_full_level if parser
    end

    on /^\/(\.|,) / do
      if parser
        if parser.get_html_from_url
          message.text[3..-1].strip.split(' ').each do |code|
            parser.send_code(code)
          end
        else
          answer_with_message parser.errors.join("\n") if parser.errors.count > 0
          parser.errors = []
        end
      end
    end

    on /^\/(\.|,)/ do
      if parser
        if parser.get_html_from_url
          parser.send_code(message.text[2..-1].strip)
        else
          answer_with_message parser.errors.join("\n") if parser.errors.count > 0
          parser.errors = []
        end
      end
    end

    on /^\.setlogin / do
      parser.login = message.text[10..-1].strip if parser
    end

    on /^\.setpassword / do
      parser.password = message.text[13..-1].strip if parser
    end

    on /^\/setchatcurrent$/ do
      @chat = message.chat
    end

    on /^\/stoptimer$/ do
      @start_timer = false
    end

    on /^\/starttimer$/ do
      @timer_interval = 5
      @start_timer = true
    end

    on /^\/starttimer / do
      @timer_interval = message.text[12..-1].strip.to_i
      @start_timer = true
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
    answer_with_message "Hello, #{message.from.first_name}"
  end

  def answer_with_farewell_message
    answer_with_message 'farewell_message'
  end

  def send_updated_level(chat: message.chat)
    if parser.get_html_from_url
      parser.parse_content(true)
      parser.question_texts_new.each do |mess|
        parser.question_texts.push(mess)
      end
      if parser.question_texts_new.count > 0
        message_str = parser.question_texts_new.join("\n")
        if message_str.length < 4000
          answer_with_message message_str, chat
        else
          message_str.chars.each_slice(4000).map(&:join).each do |msg|
            answer_with_message msg, chat
          end
        end
      end
      parser.question_texts_new = []
    else
      answer_with_message parser.errors.join("\n"), chat if parser.errors.count > 0
      parser.errors = []
    end
  end

  def send_full_level(chat: message.chat)
    if parser.get_html_from_url
      full_info = parser.parse_full_info
      if full_info.count > 0
        message_str = full_info.join("\n")
        if message_str.length < 4000
          answer_with_message message_str, chat
        else
          message_str.chars.each_slice(4000).map(&:join).each do |msg|
            answer_with_message msg, chat
          end
        end
      end
    else
      answer_with_message parser.errors.join("\n"), chat if parser.errors.count > 0
      parser.errors = []
    end
  end

  def send_needed_sectors(chat: message.chat)
    if parser.get_html_from_url
      needed_sectors = parser.parse_needed_sectors
      answer_with_message "Осталось закрити:\n#{needed_sectors.join(', ')}", chat if needed_sectors.count > 0
    else
      answer_with_message parser.errors.join("\n"), chat if parser.errors.count > 0
      parser.errors = []
    end
  end

  def answer_with_message(text, chat: message.chat)
    MessageSender.new(bot: bot, chat: chat, text: text).send
  end
end
