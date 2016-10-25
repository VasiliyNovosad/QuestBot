# /start http://kiev.quest.ua/gameengines/encounter/play/54104
# .setlogin login
# .setpassword password
# /setchatcurrent
# /starttimer


require 'telegram/bot'
require 'eventmachine'
require 'openssl'
require_relative 'quest_parser'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

$token = '171556746:AAEd8YJrYhFsiLjVEkyIk2cmluEf2lWkA5s'
$parser = nil
$chat_id = nil#-24142491 # message.chat.id
$start_timer = false
$current_bot = nil
$current_chat_id = nil

def run_bot
  Telegram::Bot::Client.run($token) do |bot|
    $current_bot = bot
    bot.listen do |message|
      $current_chat_id = message.chat.id
      p "Message #{message.text} from #{message.from.first_name} #{message.from.last_name}"
      case message.text
        when '/start'
          bot.api.sendMessage(chat_id: $chat_id || message.chat.id, text: "Hello, #{message.from.first_name}")
        when /^\/start /
          $parser = QuestParser.new(message.text[7..-1].strip, 'link')
          p $parser.url
        when '/+', '/parse'
            if $parser
              if $parser.get_html_from_url
                $parser.parse_content(true)
                $parser.question_texts_new.each do |mess|
                  $parser.question_texts.push(mess)
                end
                if $parser.question_texts_new.count > 0
                  message_str = $parser.question_texts_new.join("\n")
                  if message_str.length < 4000
                    bot.api.sendMessage(chat_id: $chat_id || message.chat.id, text: message_str)
                  else
                    message_str.chars.each_slice(4000).map(&:join).each do |msg|
                      bot.api.sendMessage(chat_id: $chat_id || message.chat.id, text: msg)
                    end
                  end
                end
                $parser.question_texts_new = []
              else
                bot.api.sendMessage(chat_id: $chat_id || message.chat.id, text: $parser.errors.join("\n")) if $parser.errors.count > 0
                $parser.errors = []
              end
            end
        when '/++'
          if $parser
            if $parser.get_html_from_url
              $parser.parse_content(true)
              $parser.question_texts_new.each do |mess|
                $parser.question_texts.push(mess)
              end
              if $parser.question_texts_new.count > 0
                message_str = $parser.question_texts_new.join("\n")
                if message_str.length < 4000
                  bot.api.sendMessage(chat_id: message.chat.id, text: message_str)
                else
                  message_str.chars.each_slice(4000).map(&:join).each do |msg|
                    bot.api.sendMessage(chat_id: message.chat.id, text: msg)
                  end
                end
              end
              $parser.question_texts_new = []
            else
              bot.api.sendMessage(chat_id: message.chat.id, text: $parser.errors.join("\n")) if $parser.errors.count > 0
              $parser.errors = []
            end
          end
        when '/-'
          if $parser
            if $parser.get_html_from_url
              messages = $parser.parse_needed_sectors
              bot.api.sendMessage(chat_id: $chat_id || message.chat.id, text: "Осталось закрити:\n#{messages.join(', ')}") if messages.count > 0
            else
              bot.api.sendMessage(chat_id: $chat_id || message.chat.id, text: $parser.errors.join("\n")) if $parser.errors.count > 0
              $parser.errors = []
            end
          end
        when '/--'
          if $parser
            if $parser.get_html_from_url
              messages = $parser.parse_needed_sectors
              bot.api.sendMessage(chat_id: message.chat.id, text: "Осталось закрити:\n#{messages.join(', ')}") if messages.count > 0
            else
              bot.api.sendMessage(chat_id: message.chat.id, text: $parser.errors.join("\n")) if $parser.errors.count > 0
              $parser.errors = []
            end
          end
        when '/*'
          if $parser
            if $parser.get_html_from_url
              messages = $parser.parse_full_info
              if messages.count > 0
                message_str = messages.join("\n")
                if message_str.length < 4000
                  bot.api.sendMessage(chat_id: $chat_id || message.chat.id, text: message_str)
                else
                  message_str.chars.each_slice(4000).map(&:join).each do |msg|
                    bot.api.sendMessage(chat_id: $chat_id || message.chat.id, text: msg)
                  end
                end
              end
            else
              bot.api.sendMessage(chat_id: $chat_id || message.chat.id, text: $parser.errors.join("\n")) if $parser.errors.count > 0
              $parser.errors = []
            end
          end
        when '/**'
          if $parser
            if $parser.get_html_from_url
              messages = $parser.parse_full_info
              if messages.count > 0
                message_str = messages.join("\n")
                if message_str.length < 4000
                  bot.api.sendMessage(chat_id: message.chat.id, text: message_str)
                else
                  message_str.chars.each_slice(4000).map(&:join).each do |msg|
                    bot.api.sendMessage(chat_id: message.chat.id, text: msg)
                  end
                end
              end
            else
              bot.api.sendMessage(chat_id: message.chat.id, text: $parser.errors.join("\n")) if $parser.errors.count > 0
              $parser.errors = []
            end
          end
        when /^\/(\.|,)/
          p message.text[2..-1].strip
          if $parser.get_html_from_url
            $parser.send_code(message.text[2..-1].strip)
          else
            bot.api.sendMessage(chat_id: $chat_id || message.chat.id, text: $parser.errors.join("\n")) if $parser.errors.count > 0
            $parser.errors = []
          end
        when /^\.setlogin /
          $parser.login = message.text[10..-1].strip if $parser
        when /^\.setpassword /
          $parser.password = message.text[13..-1].strip if $parser
        when '/setchatcurrent'
          $chat_id = message.chat.id
        when /^\.setchat /
          $chat_id = message.text[9..-1].strip.to_i
        when '/stoptimer'
          $start_timer = false
        when '/starttimer'
          $start_timer = true
      end
    end
  end
end

def run_em
  EM.run do
    EM.add_periodic_timer(5) do
      if $start_timer && $current_bot
        if $parser
          p "-------Timer start---------#{Time.now}"
          if $parser.get_html_from_url
            $parser.parse_content(false)
            $parser.question_texts_new.each do |mess|
              $parser.question_texts.push(mess)
            end
            if $chat_id && $parser.question_texts_new.count > 0
              message_str = $parser.question_texts_new.join("\n")
              if message_str.length < 4000
                $current_bot.api.sendMessage(chat_id: $chat_id, text: message_str)
              else
                message_str.chars.each_slice(4000).map(&:join).each do |msg|
                  $current_bot.api.sendMessage(chat_id: $chat_id, text: msg)
                end
              end
              $parser.question_texts_new = []
            end
          else
            p $parser.errors
            $current_bot.api.sendMessage(chat_id: $chat_id, text: $parser.errors.join("\n")) if $chat_id && $parser.errors.count > 0
            $parser.errors = []
          end
          p "-------Timer end---------#{Time.now}"
        end
      end
    end
  end
end

threads = []
threads << Thread.new{ run_bot }
threads << Thread.new{ run_em }
threads.each &:join


