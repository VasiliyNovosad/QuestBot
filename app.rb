# /start_http://lutsk.quest.ua/gameengines/encounter/play/55442

require 'telegram/bot'
require 'eventmachine'
require_relative 'quest_parser'

$token = '171556746:AAEd8YJrYhFsiLjVEkyIk2cmluEf2lWkA5s'
$parser = nil
$chat_id = nil#-24142491 # message.chat.id
$stop_event = false
$current_bot = nil
$current_chat_id = nil

def run_bot
  Telegram::Bot::Client.run($token) do |bot|
    $current_bot = bot
    bot.listen do |message|
      $current_chat_id = message.chat.id
      case message.text
        when '/start'
          bot.api.sendMessage(chat_id: $chat_id || message.chat.id, text: "Hello, #{message.from.first_name}")
        when /^\/start /
          # parser = QuestParser.new('http://lutsk.quest.ua/gameengines/encounter/play/50445', 'link')
          $parser = QuestParser.new(message.text[7..-1].strip, 'link')
          p $parser.url
        when '/+', '/parse'

            if $parser
              if $parser.get_html_from_url
                $parser.parse_content
                $parser.question_texts_new.each do |mess|
                  $parser.question_texts.push(mess)
                end
                bot.api.sendMessage(chat_id: $chat_id || message.chat.id, text: $parser.question_texts_new.join("\n")) if $parser.question_texts_new.count > 0
                $parser.question_texts_new = []
              else
                bot.api.sendMessage(chat_id: $chat_id || message.chat.id, text: $parser.errors.join("\n")) if $parser.errors.count > 0
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
        when '/*'
          if $parser
            if $parser.get_html_from_url
              messages = $parser.parse_full_info
              bot.api.sendMessage(chat_id: $chat_id || message.chat.id, text: messages.join("\n")) if messages.count > 0
            else
              bot.api.sendMessage(chat_id: $chat_id || message.chat.id, text: $parser.errors.join("\n")) if $parser.errors.count > 0
              $parser.errors = []
            end
          end
        when /^\/(\.|,)/
          p message.text[2..-1].strip
          if $parser.get_html_from_url
            $parser.send_code(message.text[2..-1].strip)
            $parser.get_html_from_url
            $parser.parse_content
            if $parser.level_name != $parser.level_name_new
              $parser.level_name = $parser.level_name_new
            end
            $parser.question_texts_new.each do |mess|
              $parser.question_texts.push(mess)
            end
            bot.api.sendMessage(chat_id: $chat_id || message.chat.id, text: $parser.question_texts_new.join("\n")) if $parser.question_texts_new.count > 0
            $parser.question_texts_new = []
          else
            bot.api.sendMessage(chat_id: $chat_id || message.chat.id, text: $parser.errors.join("\n")) if $parser.errors.count > 0
            $parser.errors = []
          end
        when /^\.setlogin /
          $parser.login = message.text[10..-1].strip
        when /^\.setpassword /
          $parser.password = message.text[13..-1].strip
        when '/setchatcurrent'
          $chat_id = message.chat.id
        when /^\.setchat /
          $chat_id = message.text[9..-1].strip.to_i
        when /^\.stop /
          $stop_event = true
      end
    end
  end
end

def run_em
  EM.run do
    EM.add_periodic_timer(15) do
      puts "Tick ..."
      p $stop_event
      puts $current_bot
      puts $parser
      puts $chat_id
      if !$stop_event && $current_bot
        if $parser
          if $parser.get_html_from_url
            $parser.parse_content
            $parser.question_texts_new.each do |mess|
              $parser.question_texts.push(mess)
            end
            $current_bot.api.sendMessage(chat_id: $chat_id, text: $parser.question_texts_new.join("\n")) if $chat_id && $parser.question_texts_new.count > 0
            $parser.question_texts_new = []
          else
            $current_bot.api.sendMessage(chat_id: $chat_id, text: $parser.errors.join("\n")) if $chat_id && $parser.errors.count > 0
            $parser.errors = []
          end
        end
      end
    end
  end
end

t1 = Thread.new{ run_bot }
t2 = Thread.new{ run_em }
t1.join
t2.join

