require 'telegram/bot'
require_relative 'quest_parser'

token = '171556746:AAEd8YJrYhFsiLjVEkyIk2cmluEf2lWkA5s'
Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    case message.text
      when '/start'
        bot.api.sendMessage(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}")
      when '/start_quest'
        parser = QuestParser.new('https://cloclo26.cldmail.ru/s5wznAqt9XFC98kfg2Q/G/634V/ZjAYVqBHJ?key=b73e6de189d6c2928dcb7fed0a20950b25425556', 'link')
        p parser.url
        #bot.api.sendMessage(chat_id: message.chat.id, text: parser.url)
      when '/parse'
        # if parser
          parser.get_html_from_url
          parser.parse_content
          if parser.level_name != parser.level_name_new
            parser.level_name = parser.level_name_new
            bot.api.sendMessage(chat_id: message.chat.id, text: parser.level_name)
          end
        # end
    end
  end
end

