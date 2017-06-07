# /start http://lutsk.quest.ua/gameengines/encounter/play/57921
# .setlogin login
# .setpassword password
# /setchatcurrent
# /starttimer


require 'telegram/bot'
require 'openssl'
require_relative 'quest_parser'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

$token = '171556746:AAEd8YJrYhFsiLjVEkyIk2cmluEf2lWkA5s'
$parser = nil
$chat_id = nil # -24142491 # message.chat.id
$start_timer = false
$current_bot = nil
$current_chat_id = nil
$timer_interval = 5
$message_str = nil

def run_bot
  Telegram::Bot::Client.run($token) do |bot|
    $current_bot = bot
    bot.listen do |message|
      $current_chat_id = message.chat.id
      p "Message #{message.text} from #{message.from.first_name} #{message.from.last_name}"
      case message.text
        when '/start'
          bot.api.sendMessage(chat_id: $chat_id || message.chat.id, text: "Hello, #{message.from.first_name}")
        when '/stop'
          $parser = nil
          $chat_id = nil
        when /^\/start /
          $parser = QuestParser.new(message.text[7..-1].strip, 'link')
          # p $parser.url
        when '/restart'
          if $parser
            url = $parser.url
            login = $parser.login
            password = $parser.password
            $parser = nil
            $parser = QuestParser.new(url, 'link')
            $parser.login = login
            $parser.password = password
          end
        when '.help'
          bot.api.sendMessage(chat_id: $chat_id || message.chat.id,
                              text: "List of commands:
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
/.<answer>  /,<answer>")
        when '/+', '/parse'
          send_updated_level(bot, $chat_id || message.chat.id, $parser)
        when '/++'
          send_updated_level(bot, message.chat.id, $parser)
        when '/-'
          send_needed_sectors(bot, $chat_id || message.chat.id, $parser)
        when '/--'
          send_needed_sectors(bot, message.chat.id, $parser)
        when '/*'
          send_full_level(bot, $chat_id || message.chat.id, $parser)
        when '/**'
          send_full_level(bot, message.chat.id, $parser)
        when /^\/(\.|,) /
          if $parser
            # p message.text[2..-1].strip
            if $parser.get_html_from_url
              message.text[3..-1].strip.split(' ').each do |code|
                $parser.send_code(code)
              end
            else
              bot.api.sendMessage(chat_id: $chat_id || message.chat.id, text: $parser.errors.join("\n")) if $parser.errors.count > 0
              $parser.errors = []
            end
          end
        when /^\/(\.|,)/
          if $parser
            # p message.text[2..-1].strip
            if $parser.get_html_from_url
              $parser.send_code(message.text[2..-1].strip)
            else
              bot.api.sendMessage(chat_id: $chat_id || message.chat.id, text: $parser.errors.join("\n")) if $parser.errors.count > 0
              $parser.errors = []
            end
          end
        when /^\.setlogin /
          if $parser
            $parser.login = message.text[10..-1].strip if $parser
          end
        when /^\.setpassword /
          if $parser
            $parser.password = message.text[13..-1].strip if $parser
          end
        when '/setchatcurrent'
          $chat_id = message.chat.id
        when /^\.setchat /
          $chat_id = message.text[9..-1].strip.to_i
        when '/stoptimer'
          $start_timer = false
        when '/starttimer'
          $timer_interval = 5
          $start_timer = true
        when /^\/starttimer /
          $timer_interval = message.text[12..-1].strip.to_i
          $start_timer = true
      end
    end
  end
end

def run_em
  loop do
    if $start_timer && $current_bot
      if $parser
        # p "-------Timer start---------#{Time.now}"
        if $parser.get_html_from_url
          $parser.parse_content(false)
          if $chat_id && $parser.question_texts_new.count > 0
            $parser.question_texts_new.each do |mess|
              $parser.question_texts.push(mess)
            end
            $message_str = $parser.question_texts_new.join("\n")
            if $message_str.length < 4000
              $current_bot.api.sendMessage(chat_id: $chat_id, text: $message_str)
            else
              $message_str.chars.each_slice(4000).map(&:join).each do |msg|
                $current_bot.api.sendMessage(chat_id: $chat_id, text: msg)
              end
            end
            $message_str = nil
            $parser.question_texts_new = []
          end
        else
          # p $parser.errors
          $current_bot.api.sendMessage(chat_id: $chat_id, text: $parser.errors.join("\n")) if $chat_id && $parser.errors.count > 0
          $parser.errors = []
        end
        # p "-------Timer end---------#{Time.now}"
      end
    end
    sleep $timer_interval
  end
end

def send_updated_level(bot, chat_id, parser)
  if parser
    if parser.get_html_from_url
      parser.parse_content(true)
      parser.question_texts_new.each do |mess|
        parser.question_texts.push(mess)
      end
      if parser.question_texts_new.count > 0
        message_str = parser.question_texts_new.join("\n")
        if message_str.length < 4000
          bot.api.sendMessage(chat_id: chat_id, text: message_str)
        else
          message_str.chars.each_slice(4000).map(&:join).each do |msg|
            bot.api.sendMessage(chat_id: chat_id, text: msg)
          end
        end
      end
      parser.question_texts_new = []
    else
      bot.api.sendMessage(chat_id: chat_id, text: parser.errors.join("\n")) if parser.errors.count > 0
      parser.errors = []
    end
  end
end

def send_full_level(bot, chat_id, parser)
  if parser
    if parser.get_html_from_url
      full_info = parser.parse_full_info
      if full_info.count > 0
        message_str = full_info.join("\n")
        if message_str.length < 4000
          bot.api.sendMessage(chat_id: chat_id, text: message_str)
        else
          message_str.chars.each_slice(4000).map(&:join).each do |msg|
            bot.api.sendMessage(chat_id: chat_id, text: msg)
          end
        end
      end
    else
      bot.api.sendMessage(chat_id: chat_id, text: parser.errors.join("\n")) if parser.errors.count > 0
      parser.errors = []
    end
  end
end

def send_needed_sectors(bot, chat_id, parser)
  if parser
    if parser.get_html_from_url
      needed_sectors = parser.parse_needed_sectors
      bot.api.sendMessage(chat_id: chat_id, text: "Осталось закрити:\n#{needed_sectors.join(', ')}") if needed_sectors.count > 0
    else
      bot.api.sendMessage(chat_id: chat_id, text: parser.errors.join("\n")) if parser.errors.count > 0
      parser.errors = []
    end
  end
end

threads = []
threads << Thread.new { run_bot }
threads << Thread.new { run_em }
threads.map(&:join)


