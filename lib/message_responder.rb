require './lib/message_sender'
require './lib/quest_parser_json'
require './lib/app_configurator'
require './lib/morze'
require './lib/braille'

class MessageResponder
  attr_accessor :message, :blocked_answer
  attr_reader :bot, :logger, :admin_id, :personal_chat_id
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
    @admin_id = (ENV['ADMIN_ID']).to_i
    @personal_chat_id = (ENV['PERSONAL_CHAT_ID']).to_i
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

#     on %r{^\/help$} do
#       logger.debug "@#{message.from.username}: #{message.text}"
#       text = 'List of commands:
# /start <domain_name>;<game_id>
# /stop
# /restart
# /starttimer
# /starttimer <secs>
# /stoptimer
# /+
# /\\*
# /-
# /-+
# /. <answer1> <answer2> ... <answern>
# . <answer1> <answer2> ... <answern>
# /.<answer> or /,<answer> or .<answer> or ,<answer>'
#       answer_with_message(text, chat || message.chat)
#     end

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
          text << result ? "+ #{code.gsub("_", "\\_").gsub("*", "\\*")}\n" : "- #{code.gsub("_", "\\_").gsub("*", "\\*")}\n"
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
      return if code.strip == '' || code[0] == ' '
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

    on %r{^\/setlogin } do
      logger.debug "@#{message.from.username}: #{message.text}"
      return if message.from.id != admin_id
      return if message.chat.id != personal_chat_id
      puts parser
      parser.login = message.text[10..-1].strip if parser
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

    on %r{^\/setpassword } do
      logger.debug "@#{message.from.username}: #{message.text}"
      return if message.from.id != admin_id
      return if message.chat.id != personal_chat_id
      puts parser
      parser.password = message.text[13..-1].strip if parser
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

    on %r{^\/morze } do
      # logger.debug "@#{message.from.username}: #{message.text}"
      text = message.text[7..-1].strip
      return if text == '' or text.nil?
      answer = "Морзе\n"
      answer << "En: #{Morze.code_to_text_en(text)}\n"
      answer << "Ukr: #{Morze.code_to_text_ukr(text)}\n"
      answer << "Rus: #{Morze.code_to_text_rus(text)}"
      answer_with_message answer, chat || message.chat
    end

    on %r{^\/brail } do
      # logger.debug "@#{message.from.username}: #{message.text}"
      text = message.text[7..-1].strip
      return if text == '' or text.nil?
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
  end

  def send_message_by_timer
    send_updated_level(chat, false) if start_timer && parser
  end

  private

  def on regex, &block
    regex =~ message.text

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
    send_level_text(updated_info, chat) unless updated_info.nil?
  end

  def send_full_level(chat)
    full_info = parser.full_info
    send_level_text(full_info, chat) unless full_info.nil?
  end

  def send_needed_sectors(chat)
    needed_sectors = parser.parse_needed_sectors
    answer_with_message needed_sectors, chat unless needed_sectors.nil?
  end

  def send_bonuses(chat)
    bonuses = parser.parse_bonuses
    answer_with_message bonuses, chat unless bonuses.nil?
  end

  def send_all_sectors(chat)
    all_sectors = parser.parse_all_sectors
    answer_with_message all_sectors, chat unless all_sectors.nil?
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
end
