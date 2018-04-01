require './lib/message_sender'
require './lib/quest_parser_json'
require './lib/app_configurator'
require './lib/morze'
require './lib/braille'
require './lib/lutsk_street'
require './models/user'
# require 'ruby_kml'

class MessageResponder
  attr_accessor :message, :blocked_answer
  attr_reader :bot, :logger, :admin_id, :personal_chat_id, :user
  attr_accessor :parser, :chat, :timer_interval, :start_timer, :block_answer

  def initialize(options)
    @bot = options[:bot]
    @message = options[:message]
    @logger = options[:logger]
    @timer_interval = 5
    @start_timer = false
    @chat = @message.chat
    @parser = nil
    @block_answer = false
    @blocked_answer = true
    @admin_id = (ENV['ADMIN_ID'] || AppConfigurator.get_admin_id).to_i
    @personal_chat_id = (ENV['PERSONAL_CHAT_ID'] || AppConfigurator.get_personal_chat_id).to_i
    logger.debug "@admin_id: #{@admin_id}"
    logger.debug "@personal_chat_id: #{@personal_chat_id}"
  end

  def respond
    on %r{^\/start$} do
      logger.debug "@#{message.from.username}: #{message.text}"
      answer_with_greeting_message
    end

    on %r{^\/stop$} do
      logger.debug "@#{message.from.username}: #{message.text}"
      return if message.from.id != admin_id
      return if message.chat.id != personal_chat_id
      @parser = nil
      @chat = nil
    end

    on %r{^\/start } do
      logger.debug "@#{message.from.username}: #{message.text}"
      return if message.from.id != admin_id
      return if message.chat.id != personal_chat_id
      @parser = QuestParserJson.new(
        message.text[7..-1].strip.split(';')[0],
        message.text[7..-1].strip.split(';')[1]
      )
      puts @parser
      @chat = message.chat
    end

    on %r{^\/restart$} do
      logger.debug "@#{message.from.username}: #{message.text}"
      return if message.from.id != admin_id
      return if message.chat.id != personal_chat_id
      if parser
        domain_name = parser.domain_name
        game_id = parser.game_id
        login = parser.login
        password = parser.password
        @parser = nil
        @parser = QuestParserJson.new(domain_name, game_id)
        @parser.login = login
        @parser.password = password
      end
    end

    on %r{^\/help$} do
      logger.debug "@#{message.from.username}: #{message.text}"
      text = 'Список команд:
/start <domain\\_name>;<game\\_id> - (!) встановити домен і ІД гри
/setlogin <login> - (!) ввести логін гравця в движку
/setpassword <password> - (!) ввести пароль гравця в движку
/setchatcurrent - вказати чат для виведення інформації ботом
/stop - (!) зупинити бот
/restart - (!) перезапустити бот
/starttimer - (!) запустити оновлення по таймеру (стандартно 5 секунд)
/starttimer <secs> - (!) запустити оновлення по таймеру через вказану кількість секунд (стандартно 5 секунд)
/stoptimer - (!) зупинити оновлення по таймеру
/on - (!) включити введення кодів через бот (стандартно включено)
/off - (!) відключити введення кодів через бот (стандартно включено)
/blon - (!) включити введення кодів на рівні із обмеженням вводу (стандартно виключено)
/bloff - (!) відключити введення кодів на рівні із обмеженням вводу (стандартно виключено)
/updon - (!) включити виведення інформації про закриті сектори і бонуси (стандартно включено)
/updoff - (!) відключити виведення інформації про закриті сектори і бонуси (стандартно включено)
/setnotifytime <min> - (!) встановити, за який час до апу або підказки виводити повідомлення (стандартно 5 хвилин)

/+ - вивести оновлення рівня
/\\* - вивести повну інформацію рівня
/- - вивести незакриті сектори
/-+ - вивести усі сектори із вірними кодами для закритих
/. <answer1> <answer2> ... <answern> - вбити одразу кілька кодів через пробіл (після точки поставити пробіл)
/.<answer> or /,<answer> or .<answer> or ,<answer> - вбити код
/: or /; - вивести всі бонуси
/coords - створити kml-файл із координатами рівня
/coords2 - створити gpx-файл із координатами рівня

/morze <code> - декодувати азбуку Морзе (задається 1 - тире і 0 - точка, наприклад 000 111 000 - СОС)
/brail <code> - декодувати шрифт Брайля (1 - чорна точка, 0 - біла, нумерація лівий стовпчик 1-3, правий 4-6)
/mend - показати таблицю Менделєєва
/flagen - показати прапорцеву азбуку латинницю
/flagru - показати прапорцеву азбуку кирилицю
/flags - показати прапори країн світу
/dance - показати танцюючі чоловічки
/masson - показати масонську азбуку
/moon - показати шрифт Муна
/shadow - показати шрифт
/semafor - показати семафорку
/brailen - показати шрифт Брайля латинницю
/brailru - показати шрифт Брайля кирилицю
/morzeen - показати азбуку Морзе латинницю
/morzeru - показати азбуку Морзе кирилицю
/alph - показати англійський, російський і український алфавіт з нумерацією
/ascii - показати таблицю кодів ascii
/kb - показати клавіатуру
/street <filter\\_regex> - вивести назви вулиць (лише Луцьк)'
      answer_with_message(text, message.chat)
    end

    on %r{^\/\+$} do
      logger.debug "@#{message.from.username}: #{message.text}"
      return if chat.id != message.chat.id && message.chat.id != personal_chat_id
      send_updated_level(chat || message.chat, true) if parser
    end

    on %r{^\/\+\+$} do
      logger.debug "@#{message.from.username}: #{message.text}"
      return if chat.id != message.chat.id && message.chat.id != personal_chat_id
      send_updated_level(message.chat, true) if parser
    end

    on %r{^\/parse$} do
      logger.debug "@#{message.from.username}: #{message.text}"
      return if chat.id != message.chat.id && message.chat.id != personal_chat_id
      send_updated_level(chat || message.chat) if parser
    end

    on %r{^\/-$} do
      logger.debug "@#{message.from.username}: #{message.text}"
      return if chat.id != message.chat.id && message.chat.id != personal_chat_id
      send_needed_sectors(chat || message.chat) if parser
    end

    on %r{^\/--$} do
      logger.debug "@#{message.from.username}: #{message.text}"
      return if chat.id != message.chat.id && message.chat.id != personal_chat_id
      send_needed_sectors(message.chat) if parser
    end

    on %r{^\/[:;]$} do
      logger.debug "@#{message.from.username}: #{message.text}"
      return if chat.id != message.chat.id && message.chat.id != personal_chat_id
      send_bonuses(chat || message.chat) if parser
    end

    on %r{^\/-\+$} do
      logger.debug "@#{message.from.username}: #{message.text}"
      return if chat.id != message.chat.id && message.chat.id != personal_chat_id
      send_all_sectors(chat || message.chat) if parser
    end

    on %r{^\/--\+$} do
      logger.debug "@#{message.from.username}: #{message.text}"
      return if chat.id != message.chat.id && message.chat.id != personal_chat_id
      send_all_sectors(message.chat) if parser
    end

    on %r{^\/\*$} do
      logger.debug "@#{message.from.username}: #{message.text}"
      return if chat.id != message.chat.id && message.chat.id != personal_chat_id
      send_full_level(chat || message.chat) if parser
    end

    on %r{^\/\*\*$} do
      logger.debug "@#{message.from.username}: #{message.text}"
      return if chat.id != message.chat.id && message.chat.id != personal_chat_id
      send_full_level(message.chat) if parser
    end

    on %r{^\/[.,] } do
      logger.debug "@#{message.from.username}: #{message.text}"
      return if parser.nil?
      return if chat.id != message.chat.id && message.chat.id != personal_chat_id
      text = ''
      if block_answer
        text = '*Ввід через бот відключено*'
        answer_with_message text, chat || message.chat
        return
      end
      if parser.level.has_answer_block_rule && blocked_answer
        text = '*Обмеження на ввід*. Ввід через бот відключено'
        answer_with_message text, chat || message.chat
        return
      end
      codes = message.text[3..-1].strip.downcase.split(' ')
      codes.each do |code|
        result = parser.send_answer(code)
        result = parser.send_answer(code) if result.nil?
        if result.nil?
          text << "помилка надсилання: #{code.gsub("_", "\\_").gsub("*", "\\*")}"
        else
          text << (result ? "+ #{code.gsub("_", "\\_").gsub("*", "\\*")}\n" : "- #{code.gsub("_", "\\_").gsub("*", "\\*")}\n")
        end
        sleep 0.1
      end
      answer_with_message text, chat || message.chat
    end

    # on %r{^[.,] } do
    #   logger.debug "@#{message.from.username}: #{message.text}"
    #   return if parser.nil?
    #   return if chat.id != message.chat.id && message.chat.id != personal_chat_id
    #   codes = message.text[2..-1].strip.downcase.split(' ')
    #   text = ''
    #   if block_answer
    #     text = '*Ввід через бот відключено*'
    #     answer_with_message text, chat || message.chat
    #     return
    #   end
    #   if parser.level.has_answer_block_rule && blocked_answer
    #     text = '*Обмеження на ввід*. Ввід через бот відключено'
    #     answer_with_message text, chat || message.chat
    #     return
    #   end
    #   codes.each do |code|
    #     result = parser.send_answer(code)
    #     result = parser.send_answer(code) if result.nil?
    #     if result.nil?
    #       text << "помилка надсилання: #{code.gsub("_", "\\_").gsub("*", "\\*")}"
    #     else
    #       text << (result ? "+ #{code.gsub("_", "\\_").gsub("*", "\\*")}\n" : "- #{code.gsub("_", "\\_").gsub("*", "\\*")}\n")
    #     end
    #     sleep 0.3
    #   end
    #   answer_with_message text, chat || message.chat
    # end

    on %r{^\/[.,]} do
      logger.debug "@#{message.from.username}: #{message.text}"
      return if parser.nil?
      return if chat.id != message.chat.id && message.chat.id != personal_chat_id
      if block_answer
        text = '*Ввід через бот відключено*'
        answer_with_message text, chat || message.chat
        return
      end
      if parser.level.has_answer_block_rule && blocked_answer
        text = '*Обмеження на ввід*. Ввід через бот відключено'
        answer_with_message text, chat || message.chat
        return
      end
      code = message.text[2..-1]
      return if code.strip == '' || code[0] == ' '
      code = code.strip.downcase
      result = parser.send_answer(code)
      result = parser.send_answer(code) if result.nil?
      # p code
      # sleep 0.2
      if result.nil?
        answer_with_message "помилка надсилання: #{code.gsub("_", "\\_").gsub("*", "\\*")}", chat || message.chat
      else
        text = result ? "+ #{code.gsub("_", "\\_").gsub("*", "\\*")}" : "- #{code.gsub("_", "\\_").gsub("*", "\\*")}"
        # p text
        answer_with_message text, chat || message.chat
      end
    end

    on %r{^[.,]} do
      logger.debug "@#{message.from.username}: #{message.text}"
      return if parser.nil?
      return if chat.id != message.chat.id && message.chat.id != personal_chat_id
      if block_answer
        text = '*Ввід через бот відключено*'
        answer_with_message text, chat || message.chat
        return
      end
      if parser.level.has_answer_block_rule && blocked_answer
        text = '*Обмеження на ввід*. Ввід через бот відключено'
        answer_with_message text, chat || message.chat
        return
      end
      code = message.text[1..-1]
      return if code.strip == ''
      code = code.strip.downcase
      result = parser.send_answer(code)
      result = parser.send_answer(code) if result.nil?
      # p code
      # sleep 0.2
      if result.nil?
        answer_with_message "помилка надсилання: #{code.gsub("_", "\\_").gsub("*", "\\*")}", chat || message.chat
      else
        text = result ? "*+* #{code.gsub("_", "\\_").gsub("*", "\\*")}" : "*-* #{code.gsub("_", "\\_").gsub("*", "\\*")}"
        # p text
        answer_with_message text, chat || message.chat
      end
    end

    on %r{^\/off$} do
      logger.debug "@#{message.from.username}: #{message.text}"
      return if message.from.id != admin_id
      return if message.chat.id != personal_chat_id
      @block_answer = true
    end

    on %r{^\/on$} do
      logger.debug "@#{message.from.username}: #{message.text}"
      return if message.from.id != admin_id
      return if message.chat.id != personal_chat_id
      @block_answer = false
    end

    on %r{^\/bloff$} do
      logger.debug "@#{message.from.username}: #{message.text}"
      return if message.from.id != admin_id
      return if message.chat.id != personal_chat_id
      @blocked_answer = true
    end

    on %r{^\/blon$} do
      logger.debug "@#{message.from.username}: #{message.text}"
      return if message.from.id != admin_id
      return if message.chat.id != personal_chat_id
      @blocked_answer = false
    end

    on %r{^\/updoff$} do
      logger.debug "@#{message.from.username}: #{message.text}"
      return if message.from.id != admin_id
      return if message.chat.id != personal_chat_id
      parser.block_sector_update = true if parser
    end

    on %r{^\/updon$} do
      logger.debug "@#{message.from.username}: #{message.text}"
      return if message.from.id != admin_id
      return if message.chat.id != personal_chat_id
      parser.block_sector_update = false if parser
    end

    on %r{^\/setlogin } do
      logger.debug "@#{message.from.username}: #{message.text}"
      return if message.from.id != admin_id
      return if message.chat.id != personal_chat_id
      puts parser
      parser.login = message.text[10..-1].strip if parser
      user = User.find_or_create_by(uid: admin_id)
      user.enlogin = message.text[10..-1].strip
      user.save!
    end

    on %r{^\/setpassword } do
      logger.debug "@#{message.from.username}: #{message.text}"
      return if message.from.id != admin_id
      return if message.chat.id != personal_chat_id
      parser.password = message.text[13..-1].strip if parser
      user = User.find_or_create_by(uid: admin_id)
      user.enpassword = message.text[13..-1].strip
      user.save!
    end

    on %r{^\/setuserlogin } do
      logger.debug "@#{message.from.username}: #{message.text}"
      user = User.find_or_create_by(uid: message.from.id)
      user.enlogin = message.text[14..-1].strip
      user.save!
    end

    on %r{^\/setuserpassword } do
      logger.debug "@#{message.from.username}: #{message.text}"
      user = User.find_or_create_by(uid: message.from.id)
      user.enpassword = message.text[17..-1].strip
      user.save!
    end

    on %r{^\/setchatcurrent$} do
      logger.debug "@#{message.from.username}: #{message.text}"
      return if message.from.id != admin_id
      # return if chat.id != message.chat.id && message.chat.id != AppConfigurator.get_personal_chat_id
      @chat = message.chat
    end

    on %r{^\/stoptimer$} do
      logger.debug "@#{message.from.username}: #{message.text}"
      return if message.from.id != admin_id
      return if message.chat.id != personal_chat_id
      @start_timer = false
    end

    on %r{^\/starttimer } do
      logger.debug "@#{message.from.username}: #{message.text}"
      return if message.from.id != admin_id
      return if message.chat.id != personal_chat_id
      @timer_interval = message.text[12..-1].strip.to_i
      @start_timer = true
    end

    on %r{^\/starttimer$} do
      logger.debug "@#{message.from.username}: #{message.text}"
      return if message.from.id != admin_id
      return if message.chat.id != personal_chat_id
      @timer_interval = 5
      @start_timer = true
    end

    on %r{^\/setnotifytime } do
      logger.debug "@#{message.from.username}: #{message.text}"
      return if message.from.id != admin_id
      return if message.chat.id != personal_chat_id
      parser.notify_before = message.text[15..-1].strip.to_i if parser
    end

    on %r{^\/morze } do
      # logger.debug "@#{message.from.username}: #{message.text}"
      text = message.text[7..-1].strip
      return if text == '' || text.nil?
      answer = "Морзе\n"
      answer << "En: #{Morze.code_to_text_en(text)}\n"
      answer << "Ukr: #{Morze.code_to_text_ukr(text)}\n"
      answer << "Rus: #{Morze.code_to_text_rus(text)}"
      answer_with_message answer, chat || message.chat
    end

    on %r{^\/brail } do
      # logger.debug "@#{message.from.username}: #{message.text}"
      text = message.text[7..-1].strip
      return if text == '' || text.nil?
      answer = "Брайль\n"
      answer << "En: #{Braille.code_to_text_en(text)}\n"
      answer << "Ukr: #{Braille.code_to_text_ukr(text)}\n"
      answer << "Rus: #{Braille.code_to_text_rus(text)}"
      answer_with_message answer, message.chat
    end

    on %r{^\/mend$} do
      answer_with_photo('/images/mendeleev.jpg', message.chat)
    end

    on %r{^\/flagen$} do
      answer_with_photo('/images/flags-en.jpg', message.chat)
    end

    on %r{^\/flagru$} do
      answer_with_photo('/images/flags-ru.jpg', message.chat)
    end

    on %r{^\/flags$} do
      answer_with_photo('/images/flags.jpg', message.chat)
    end

    on %r{^\/dance$} do
      answer_with_photo('/images/dancing.jpg', message.chat)
    end

    on %r{^\/masson$} do
      answer_with_photo('/images/masson.jpg', message.chat)
    end

    on %r{^\/moon$} do
      answer_with_photo('/images/moon-en.jpg', message.chat)
    end

    on %r{^\/shadow$} do
      answer_with_photo('/images/shadow.jpg', message.chat)
    end

    on %r{^\/semafor$} do
      answer_with_photo('/images/semafor.jpg', message.chat)
    end

    on %r{^\/brailru$} do
      answer_with_photo('/images/braille-ru.jpg', message.chat)
    end

    on %r{^\/brailen$} do
      answer_with_photo('/images/braille-en.jpg', message.chat)
    end

    on %r{^\/morzeru$} do
      answer_with_photo('/images/morze-ru.jpg', message.chat)
    end

    on %r{^\/morzeen$} do
      answer_with_photo('/images/morze-en.jpg', message.chat)
    end

    on %r{^\/alph$} do
      answer_with_photo('/images/alphabets.jpg', message.chat)
    end

    on %r{^\/ascii$} do
      answer_with_photo('/images/ascii.jpg', message.chat)
    end

    on %r{^\/kb$} do
      answer_with_photo('/images/kb.jpg', message.chat)
    end

    on %r{^\/coords$} do
      logger.debug "@#{message.from.username}: #{message.text}"
      return if message.from.id != admin_id
      return if chat.id != message.chat.id && message.chat.id != personal_chat_id
      return if parser.nil? || parser.level.nil?
      full_info = parser.full_info
      answer_with_file(coords_to_kml(parser.level.all_coords, "Рівень #{parser.level.number}"), message.chat) if parser
    end

    on %r{^\/coords2$} do
      logger.debug "@#{message.from.username}: #{message.text}"
      return if message.from.id != admin_id
      return if chat.id != message.chat.id && message.chat.id != personal_chat_id
      return if parser.nil? || parser.level.nil?
      full_info = parser.full_info
      answer_with_file(coords_to_gpx(parser.level.all_coords, "Рівень #{parser.level.number}"), message.chat) if parser
    end

    on %r{^\/street } do
      # logger.debug "@#{message.from.username}: #{message.text}"
      text = message.text[8..-1].strip
      return if text == '' || text.nil?
      answer = LutskStreet.like_name(text).join("\n")
      send_level_text answer, message.chat
    end

    on %r{^(\d{2}[.,]\d{3,}),?\s*(\d{2}[.,]\d{3,})$} do
      logger.debug message.text
      logger.debug message.location
      if message.location.nil?
        numbersRe = /(\d{2}[.,]\d{3,}),?\s*(\d{2}[.,]\d{3,})/
        mrNumbersRe = message.text.to_enum(:scan, numbersRe).map { Regexp.last_match }
        mrNumbersRe.each do |match|
          answer_with_location({ latitude: match[1], longitude: match[2]}, message.chat)
        end
      else
        answer_with_location({ latitude: message.location.latitude, longitude: message.location.longitude }, message.chat)
      end
    end
  end

  def send_message_by_timer
    send_updated_level(chat, false) if start_timer && parser
  end

  private

  def on regex, &block
    text = message.text
    text = "#{message.location.latitude}, #{message.location.longitude}" unless message.location.nil?
    regex =~ text

    return unless $~
    case block.arity
    when 0
      yield
    when 1
      yield $1
    when 2
      yield $1, $2
    else
      nil
    end
  end

  def answer_with_greeting_message
    answer_with_message "Hello, #{message.from.first_name} (id: #{message.from.id}, chat\\_id: #{message.chat.id})", message.chat
  end

  def answer_with_farewell_message
    answer_with_message 'farewell_message', message.chat
  end

  def send_updated_level(chat, with_q_time = true)
    updated_info = parser.updated_info(with_q_time)
    unless updated_info.nil?
      send_level_text(updated_info[:text], chat)
      updated_info[:coords].each do |coord|
        answer_with_location(coord, chat)
      end
    end
  end

  def send_full_level(chat)
    full_info = parser.full_info
    unless full_info.nil?
      send_level_text(full_info[:text], chat)
      full_info[:coords].each do |coord|
        answer_with_location(coord, chat)
      end
    end
  end

  def send_needed_sectors(chat)
    needed_sectors = parser.parse_needed_sectors
    unless needed_sectors.nil?
      answer_with_message needed_sectors[:text], chat
      needed_sectors[:coords].each do |coord|
        answer_with_location(coord, chat)
      end
    end
  end

  def send_bonuses(chat)
    bonuses = parser.parse_bonuses
    unless bonuses.nil?
      answer_with_message bonuses[:text], chat
      bonuses[:coords].each do |coord|
        answer_with_location(coord, chat)
      end
    end
  end

  def send_all_sectors(chat)
    all_sectors = parser.parse_all_sectors
    unless all_sectors.nil?
      answer_with_message all_sectors[:text], chat
      all_sectors[:coords].each do |coord|
        answer_with_location(coord, chat)
      end
    end
  end

  def send_errors(chat)
    text = parser.errors
    answer_with_message text.join("\n"), chat if text.count > 0
    parser.errors = []
  end

  def send_level_text(text, chat)
    message_str = text
    return if message_str.empty?
    if message_str.length < 4000
      answer_with_message message_str, chat
    else
      message_str.chars.each_slice(4000).map(&:join).each do |msg|
        answer_with_message msg, chat
      end
    end
  rescue
    return
  end

  def answer_with_message(text, chat)
    MessageSender.new(bot: bot, chat: chat, text: text).send
  end

  def answer_with_photo(file_name, chat)
    MessageSender.new(bot: bot, chat: chat, text: file_name).send_photo
  end

  def answer_with_location(coord, chat)
    MessageSender.new(bot: bot, chat: chat, latitude: coord[:latitude], longitude: coord[:longitude], name: coord[:name]).send_location
  end

  def answer_with_file(file_name, chat)
    MessageSender.new(bot: bot, chat: chat, text: file_name).send_document
  end

  def coords_to_kml(coords, level_name)
    require 'bundler/setup'
    require 'ruby_kml'
    kml = KMLFile.new
    folder = KML::Document.new(name: level_name)
    coords.each do |k, v|
      v.each_with_index do |coord, index|
        folder.features << KML::Placemark.new(
            name: "#{k}. Точка #{index + 1}",
            geometry: KML::Point.new(coordinates: {lat: coord[:latitude], lng: coord[:longitude]})
        )
      end
    end
    kml.objects << folder
    kml.render
    kml.save(File.dirname(__FILE__) + "/kml/#{level_name}.kml")
    "/kml/#{level_name}.kml"
  end

  def coords_to_gpx(coords, level_name)
    require 'gpx'
    gpx = GPX::GPXFile.new
    coords.each do |k, v|
      v.each_with_index do |coord, index|
        gpx.waypoints << GPX::Waypoint.new({name: "#{k}. Точка #{index + 1}", lat: coord[:latitude], lon: coord[:longitude], time: Time.now})
      end
    end
    gpx.write(File.dirname(__FILE__) + "/kml/#{level_name}.gpx")
    "/kml/#{level_name}.gpx"
  end
end
