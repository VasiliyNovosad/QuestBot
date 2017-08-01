class Level
  attr_reader :id, :number
  def initialize(level_json)
    load_level_from_json(level_json)
  end

  def full_info(level_json)
    load_level_from_json(level_json)
    full_level_info
  end

  def updated_info(level_json, with_q_time = false)
    if level_json['Level']['LevelId'] != @id
      full_info(level_json)
    else
      result = load_updated_info(level_json['Level'], with_q_time)
      load_level_from_json(level_json)
      result
    end
  end

  def needed_sectors(level_json)
    load_level_from_json(level_json)
    result = "Лишилось закрити *#{@sectors_left_to_close}*.\nНезакриті сектори:\n"
    @sectors.each do |sector|
      result << "#{sector[:name]}\n" unless sector[:answered]
    end
    result
  end

  def all_sectors(level_json)
    load_level_from_json(level_json)
    result = "Лишилось закрити *#{@sectors_left_to_close}*.\nCектори:\n"
    @sectors.each do |sector|
      result << "#{sector[:name]}: #{sector[:answered] ? sector[:answer][:answer] : '-'}\n"
    end
    result
  end

  def all_bonuses(level_json)
    load_level_from_json(level_json)
    result = ''
    @bonuses.each { |bonus| result << bonus_to_text(bonus) }
    result
  end

  private

  def load_level_from_json(level_json)
    levels = level_json['Levels']
    @levels_count = levels.nil? ? 0 : levels.count
    level_json = level_json['Level'] || {}
    @id = level_json['LevelId']
    @name = level_json['Name']
    @number = level_json['Number']
    @timeout_seconds_remain = level_json['TimeoutSecondsRemain']
    @has_answer_block_rule = level_json['HasAnswerBlockRule']
    @block_duration = level_json['BlockDuration']
    @block_target_id = level_json['BlockTargetId']
    @attemts_number = level_json['AttemtsNumber']
    @attemts_period = level_json['AttemtsPeriod']
    @required_sectors_count = level_json['RequiredSectorsCount']
    @passed_sectors_count = level_json['PassedSectorsCount']
    @sectors_left_to_close = level_json['SectorsLeftToClose']
    @task = ''
    if level_json['Tasks'] && level_json['Tasks'].count > 0
      @task = level_json['Tasks'][0]['TaskText']
    end
    @messages = []
    unless level_json['Messages'].nil?
      @messages = level_json['Messages'].map { |rec| json_to_message(rec) }
    end
    @sectors = []
    unless level_json['Sectors'].nil?
      @sectors = level_json['Sectors'].map { |rec| json_to_sector(rec) }
    end
    @helps = []
    unless level_json['Helps'].nil?
      @helps = level_json['Helps'].map { |rec| json_to_help(rec) }
    end
    @penalty_helps = []
    unless level_json['PenaltyHelps'].nil?
      @penalty_helps = level_json['PenaltyHelps'].map do |rec|
        json_to_penalty_help(rec)
      end
    end
    @bonuses = []
    unless level_json['Bonuses'].nil?
      @bonuses = level_json['Bonuses'].map { |rec| json_to_bonus(rec) }
    end
  end

  def answer(rec)
    { answer: rec['Answer'], user: rec['Login'] }
  end

  def full_level_info
    result = "*Рівень #{@number} із #{@levels_count}*#{": #{@name}" unless @name.nil? || @name.empty?}\n\n"
    result << "*Автоперехід* через *#{seconds_to_string(@timeout_seconds_remain)}*\n\n" if @timeout_seconds_remain > 0
    result << block_rule if @has_answer_block_rule
    result << parsed(@task)
    result << "\n\n"
    result << "Треба закрити *#{@sectors_left_to_close}* секторів із *#{@sectors.count}*\n\n" if @sectors.count > 0
    @helps.each { |help| result << help_to_text(help) }
    result << "\n" if @helps.count > 0
    @penalty_helps.each { |help| result << penalty_help_to_text(help) }
    result << "\n" if @penalty_helps.count > 0
    @bonuses.each { |bonus| result << bonus_to_text(bonus) }
    result << "\n" if @bonuses.count > 0
    @messages.each { |el| result << "*Повідомлення* від *#{el[:owner]}*: #{el[:text]}\n\n" }
    result
  end

  def help_to_text(help)
    result = "*Підказка #{help[:number]}*: "
    result << (help[:remains].zero? ? "\n#{parsed(help[:text])}\n\n" : "буде через *#{seconds_to_string(help[:remains])}*\n\n")
    result
  end

  def penalty_help_to_text(help)
    result = "*Штрафна підказка #{help[:number]}*: "
    result << (help[:remains].zero? ? parsed(help[:text]) : "буде через *#{seconds_to_string(help[:remains])}*\n\n")
    result
  end

  def bonus_to_text(bonus)
    result = "*Бонус #{bonus[:number]}#{bonus[:name].nil? || (bonus[:number].to_s == bonus[:name]) ? '' : " #{bonus[:name]}"}*: "
    result << "буде доступний через *#{seconds_to_string(bonus[:seconds_to_start])}*\n" if bonus[:seconds_to_start] > 0
    result << "закриється через *#{seconds_to_string(bonus[:seconds_left])}*\n" if bonus[:seconds_left] > 0
    result << "закрито кодом *#{bonus[:answer][:answer]}*\n" if bonus[:answered]
    result << "не закрито\n" if bonus[:expired]
    result << "*Завдання*: #{parsed(bonus[:task])}\n" unless bonus[:task].nil? || bonus[:task].empty? || bonus[:answered]
    result << "*Підказка*: #{parsed(bonus[:help])}\n" unless bonus[:help].nil? || bonus[:help].empty?
    result << "\n"
    result
  end

  def seconds_to_string(seconds, nominative = false)
    result = ''
    if seconds / 3600 > 0
      result << time_part_to_text(seconds / 3600, 'годин', nominative)
    end
    if (seconds / 60) % 60 > 0
      result << time_part_to_text((seconds / 60) % 60, 'хвилин', nominative)
    end
    if seconds % 60 > 0
      result << time_part_to_text(seconds % 60, 'секунд', nominative)
    end
    result
  end

  def time_part_to_text(count, part, nominative)
    result = ''
    case count % 10
    when 1
      result << (nominative ? "#{count} #{part}а " : "#{count} #{part}у ")
    when 2..4
      result << "#{count} #{part}и "
    else
      result << "#{count} #{part} "
    end
    result
  end

  def block_rule
    result = '*УВАГА!!! Обмеження на ввід*: '
    result << "*#{@attemts_number}* спроб на *"
    result << (@block_target_id > 1 ? 'команду' : 'гравця')
    result << "* за *#{seconds_to_string(@attemts_period)}*\n\n"
  end

  def load_updated_info(level_json, with_q_time = false)
    result = ''
    if with_q_time
      result << '*Автоперехід* через '
      result << "*#{seconds_to_string(level_json['TimeoutSecondsRemain'])}*\n\n"
    end
    result << task_updated(level_json['Tasks'])
    result << helps_updated(level_json['Helps'])
    result << bonuses_updated(level_json['Bonuses'])
    result << sectors_updated(level_json['Sectors'])
    result << messages_updated(level_json['Messages'])
    result
  end

  def helps_updated(helps_json)
    result = ''
    helps_json.each do |help_json|
      help = @helps.select { |h| h[:id] == help_json['HelpId'] }
      if help.count.zero?
        help = json_to_help(help_json)
        result << help_to_text(help)
      else
        help = help[0]
        if help[:text] != help_json['HelpText']
          help = json_to_help(help_json)
          result << help_to_text(help)
        end
      end
    end
    result
  end

  def bonuses_updated(bonuses_json)
    result = ''
    bonuses_json.each do |rec|
      bonuses = @bonuses.select { |h| h[:id] == rec['BonusId'] }
      continue if bonuses.count.zero?
      bonus = bonuses[0]
      new_bonus = json_to_bonus(rec)
      if bonus[:answered] != new_bonus[:answered] ||
          bonus[:expired] != new_bonus[:expired] ||
          bonus[:task] != new_bonus[:task] ||
          bonus[:help] != new_bonus[:help]
        result << bonus_to_text(new_bonus)
      end
    end
    result
  end

  def json_to_bonus(bonus_json)
    {
      id: bonus_json['BonusId'],
      name: bonus_json['Name'],
      number: bonus_json['Number'],
      task: bonus_json['Task'],
      help: bonus_json['Help'],
      answered: bonus_json['IsAnswered'],
      expired: bonus_json['Expired'],
      seconds_to_start: bonus_json['SecondsToStart'],
      seconds_left: bonus_json['SecondsLeft'],
      award: bonus_json['AwardTime'],
      answer: bonus_json['Answer'].nil? ? nil : answer(bonus_json['Answer'])
    }
  end

  def json_to_help(help_json)
    {
      id: help_json['HelpId'],
      number: help_json['Number'],
      text: help_json['HelpText'],
      remains: help_json['RemainSeconds']
    }
  end

  def json_to_penalty_help(help_json)
    {
      number: help_json['Number'],
      text: help_json['HelpText'],
      message: help_json['PenaltyMessage'],
      remains: help_json['RemainSeconds'],
      penalty: help_json['Penalty'],
      comment: help_json['PenaltyComment']
    }
  end

  def json_to_message(message_json)
    {
      id: message_json['MessageId'],
      owner: message_json['OwnerLogin'],
      text: message_json['MessageText']
    }
  end

  def json_to_sector(sector_json)
    {
      id: sector_json['SectorId'],
      number: sector_json['Order'],
      name: sector_json['Name'],
      answer: sector_json['Answer'].nil? ? nil : answer(sector_json['Answer']),
      answered: sector_json['IsAnswered']
    }
  end

  def sectors_updated(sectors_json)
    result = ''
    sectors_json.each do |rec|
      sectors = @sectors.select { |h| h[:id] == rec['SectorId'] }
      continue if sectors.count.zero?
      sector = sectors[0]
      new_sector = json_to_sector(rec)
      if sector[:answered] != new_sector[:answered]
        result << sector_to_text(new_sector)
      end
    end
    result
  end

  def sector_to_text(sector)
    "Сектор *#{sector[:name]}* закрито кодом *#{sector[:answer][:answer]}*\n"
  end

  def messages_updated(messages_json)
    result = ''
    messages_json.each do |message_json|
      message = @messages.select { |h| h[:id] == message_json['MessageId'] }
      if message.count.zero? || message[0][:text] != message_json['MessageText']
        result << "*Повідомлення* від *#{message_json['OwnerLogin']}*: #{message_json['MessageText']}\n\n"
      end
    end
    result
  end

  def task_updated(tasks_json)
    result = ''
    if @task != tasks_json[0]['TaskText']
      result << "#{parsed(tasks_json[0]['TaskText'])}\n\n"
    end
    result
  end

  def parsed(text)
    result = text

    ire = /<img.+?src="\s*(https?:\/\/.+?)\s*".*?>/
    # ireA = /<a.+?href=?"(https?:\/\/.+?.(jpg|png|bmp))?".*?>(.*?)<\/a>/

    reBr = /<br\s*\/?>/
    reHr = /<hr.*?\/?>/
    reP = /<p>([^ ]+?)<\/p>/
    reBold = /<b.*?\/?>(.+?)<\/b>/
    reStrong = /<strong.*?>(.*?)<\/strong>/
    reItalic = /<i>(.+?)<\/i>/
    reStyle = /<style.*?>([\s\S.]*?)<\/style>/
    reScript = /<script.*?>([\s\S.]*?)<\/script>/
    reSpan = /<span.*?>([\s\S.]*?)<\/span>/
    reCenter = /<center>(.+?)<\/center>/
    reFont = /<font.+?colors*=?["«]?#?(w+)?["»]?.*?>([\s\S.]+?)<\/font>/
    reA = /<a.+?href=?"(.+?)?".*?>(.+?)<\/a>/

    # <a href="geo:49.976136, 36.267256">49.976136, 36.267256</a>
    geoHrefRe = /<a.+?href="geo:(\d{2}[.,]\d{3,}),?\s*(\d{2}[.,]\d{3,})">(.+?)<\/a>/
    # <a href="https://www.google.com.ua/maps/@50.0363257,36.2120039,19z" target="blank">50.036435 36.211914</a>
		hrefRe = /<a.+?href="https?:\/\/.+?(\d{2}[.,]\d{3,}),?\s*(\d{2}[.,]\d{3,}).*?">(.+?)<\/a>/
    # 49.976136, 36.267256
    numbersRe = /(\d{2}[.,]\d{3,}),?\s*(\d{2}[.,]\d{3,})/


    mrStyle = result.to_enum(:scan, reStyle).map { Regexp.last_match }
    mrStyle.each { |match| result = result.gsub(match[0], '') }
    mrScript = result.to_enum(:scan, reScript).map { Regexp.last_match }
    mrScript.each { |match| result = result.gsub(match[0], '') }
    result = result.gsub("_", "\\_")
    mrFont = result.to_enum(:scan, reFont).map { Regexp.last_match }
    mrFont.each { |match| result = result.gsub(match[0], match[2]) }
    mrBold = result.to_enum(:scan, reBold).map { Regexp.last_match }
    mrBold.each { |match| result = result.gsub(match[0], "*#{match[1]}*") }
    mrStrong = result.to_enum(:scan, reStrong).map { Regexp.last_match }
    mrStrong.each { |match| result = result.gsub(match[0], "*#{match[1]}*") }
    mrItalic = result.to_enum(:scan, reItalic).map { Regexp.last_match }
    mrItalic.each { |match| result = result.gsub(match[0], "#{match[1]}") }
    mrSpan = result.to_enum(:scan, reSpan).map { Regexp.last_match }
    mrSpan.each { |match| result = result.gsub(match[0], match[1]) }
    mrCenter = result.to_enum(:scan, reCenter).map { Regexp.last_match }
    mrCenter.each { |match| result = result.gsub(match[0], match[1]) }
    mre = result.to_enum(:scan, ire).map { Regexp.last_match }
    mre.each { |match| result = result.gsub(match[0], match[1]) }
    # mreA = result.to_enum(:scan, ireA).map { Regexp.last_match }
    # mreA.each { |match| result.gsub!(match[0], "[#{match[2]}](#{match[1]})") }
    mrA = result.to_enum(:scan, reA).map { Regexp.last_match }
    mrA.each { |match| result = result.gsub(match[0], "[#{match[2]}](#{match[1]})") }
    mrP = result.to_enum(:scan, reP).map { Regexp.last_match }
    mrP.each { |match| result = result.gsub(match[0], "\n#{match[1]}") }
    mrBr = result.to_enum(:scan, reBr).map { Regexp.last_match }
    mrBr.each { |match| result = result.gsub(match[0], "\n") }
    mrHr = result.to_enum(:scan, reHr).map { Regexp.last_match }
    mrHr.each { |match| result = result.gsub(match[0], "\n") }
    mrGeoHrefRe = result.to_enum(:scan, geoHrefRe).map { Regexp.last_match }
    mrGeoHrefRe.each { |match| result = result.gsub(match[0], match[3]) }
    mrHrefRe = result.to_enum(:scan, hrefRe).map { Regexp.last_match }
    mrHrefRe.each { |match| result = result.gsub(match[0], match[3]) }
    mrNumbersRe = result.to_enum(:scan, numbersRe).map { Regexp.last_match }
    mrNumbersRe.each do |match|
      result = result.gsub(
          match[0],
          "[#{match[1]} #{match[2]}] (#{google_link(match[1], match[2])})"
      )
    end
    result = result.gsub('&nbsp;', ' ')
    result = result.gsub("\r", '')
    result = result.gsub("\n\n\n", "\n\n")
    result
  end

  def google_link(lat, lon)
    "http://maps.google.com/maps?daddr=#{lat},#{lon}&saddr=My+Location"
  end
end