require 'telegram/bot'
require_relative 'quest_parser'

token = '171556746:AAEd8YJrYhFsiLjVEkyIk2cmluEf2lWkA5s'
parser = nil
Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    chat_id = -24142491 # message.chat.id
    case message.text
      when '/start'
        # p message.chat
        bot.api.sendMessage(chat_id: chat_id, text: "Hello, #{message.from.first_name}")
      when /^\/start_/
        # parser = QuestParser.new('http://zhitomir.quest.ua/gameengines/encounter/play/41977', 'link')
        parser = QuestParser.new(message.text[7..-1], 'link')
        p parser.url
        # bot.api.sendMessage(chat_id: chat_id, text: parser.url)
      when '/+'
        if parser
          parser.get_html_from_url
          parser.parse_content
          if parser.level_name != parser.level_name_new
            parser.level_name = parser.level_name_new
            bot.api.sendMessage(chat_id: chat_id, text: parser.level_name)
          end
          parser.question_texts_new.each do |mess|
            bot.api.sendMessage(chat_id: chat_id, text: mess)
            parser.question_texts.push(mess)
          end
          parser.question_texts_new = []
        end
      when '/parse'
        if parser
          parser.get_html_from_url
          parser.parse_content
          if parser.level_name != parser.level_name_new
            parser.level_name = parser.level_name_new
            bot.api.sendMessage(chat_id: chat_id, text: parser.level_name)
          end
          parser.question_texts_new.each do |mess|
            bot.api.sendMessage(chat_id: chat_id, text: mess)
            parser.question_texts.push(mess)
          end
          parser.question_texts_new = []
        end
      when /^\/\./
        p message.text[2..-1]
        parser.get_html_from_url
        parser.send_code(message.text[2..-1])
    end
  end
end

