class Level
  def initialize(level_json)
    load_level_from_json(level_json)
  end

  def full_info(level_json)
    load_level_from_json(level_json)
    full_level_info
  end

  def updated_info(level_json)
    if level_json['Level']['LevelId'] != @id
      full_info(level_json)
    else
      result = load_updated_info(level_json['Level'])
      load_level_from_json(level_json)
      result
    end
  end

  def needed_sectors(level_json)
    load_level_from_json(level_json)
    result = "Лишилось закрити #{@sectors_left_to_close} секторів.\nНезакриті сектори:\n"
    sectors.each do |sector|
      result << "#{sector[:name]}\n" unless sector[:answered]
    end
    result
  end

  def all_sectors(level_json)
    load_level_from_json(level_json)
    result = "Лишилось закрити #{@sectors_left_to_close} секторів.\nCектори:\n"
    sectors.each do |sector|
      result << "#{sector[:name]}: #{sector[:answered] ? sector[:answer][:answer] : '-'}\n"
    end
    result
  end

  private

  def load_level_from_json(level_json)
    @levels_count = level_json['Levels'].count
    level_json = level_json['Level']
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
    @task = level_json['Tasks'][0]['TaskText']
    @messages = level_json['Messages'].map do |rec|
      {
        id: rec['MessageId'],
        owner: rec['OwnerLogin'],
        text: rec['MessageText']
      }
    end
    @sectors = level_json['Sectors'].map do |rec|
      {
        id: rec['SectorId'],
        number: rec['Order'],
        name: rec['Name'],
        answer: rec['Answer'].nil? ? nil : answer(rec['Answer']),
        answered: rec['IsAnswered']
      }
    end
    @helps = level_json['Helps'].map do |rec|
      {
        id: rec['HelpId'],
        number: rec['Number'],
        text: rec['HelpText'],
        remains: rec['RemainSeconds']
      }
    end
    @penalty_helps = level_json['PenaltyHelps'].map do |rec|
      {
        number: rec['Number'],
        text: rec['HelpText'],
        message: rec['PenaltyMessage'],
        remains: rec['RemainSeconds'],
        penalty: rec['Penalty'],
        comment: rec['PenaltyComment']
      }
    end
    @bonuses = level_json['Bonuses'].map do |rec|
      {
        id: rec['BonusId'],
        name: rec['Name'],
        number: rec['Number'],
        task: rec['Task'],
        help: rec['Help'],
        answered: rec['IsAnswered'],
        expired: rec['Expired'],
        seconds_to_start: rec['SecondsToStart'],
        seconds_left: rec['SecondsLeft'],
        award: rec['AwardTime'],
        answer: rec['Answer'].nil? ? nil : answer(rec['Answer'])
      }
    end
  end

  def answer(rec)
    { answer: rec['Answer'], user: rec['Login'] }
  end

  def full_level_info
    result = "Рівень #{@number} із #{@levels_count}"
    result << '\n\n'
    result << block_rule if @has_answer_block_rule
    result << parsed(@task)
    result << '\n'
    result << "Треба закрити #{@sectors_left_to_close} секторів із #{sectors.count}\n\n" if sectors.count > 0
    @helps.each { |help| result << help_to_text(help) }
    result << '\n' if @helps.count > 0
    @penalty_helps.each { |help| result << penalty_help_to_text(help) }
    result << '\n' if @penalty_helps.count > 0
    @bonuses.each { |bonus| result << bonus_to_text(bonus) }
    result << '\n' if @bonuses.count > 0
    @messages.each { |message| result << "#{message(:text)}\n\n" }
  end

  def help_to_text(help)
    result = "Підказка #{help[:number]}: "
    result << help[:remains].zero? ? parsed(help[:text]) : "буде через #{seconds_to_string(help[:remains])}\n\n"
    result
  end

  def penalty_help_to_text(help)
    result = "Штрафна підказка #{help[:number]}: "
    result << help[:remains].zero? ? parsed(help[:text]) : "буде через #{seconds_to_string(help[:remains])}\n\n"
    result
  end

  def bonus_to_text(bonus)
    result = "Бонус #{bonus[:number]}#{bonus[:name].nil? ? '' : " #{bonus[:name]}"}: "
    result << "буде доступний через #{seconds_to_string(bonus[:seconds_to_start])}\n" unless bonus[:seconds_to_start].nil?
    result << "закриється через #{seconds_to_string(bonus[:seconds_left])}\n" unless bonus[:seconds_left].nil?
    result << "виконано кодом #{bonus[:answer][:answer]}\n" if bonus[:answered]
    result << "не закрито\n" if bonus[:expired]
    result << "#{parsed(bonus[:task])}\n" unless bonus[:task].nil? || bonus[:task].empty?
    result << "#{parsed(bonus[:help])}\n" unless bonus[:help].nil? || bonus[:help].empty?
    result << '\n\n'
    result
  end

  def seconds_to_string(seconds, nominative = false)
    result = ''
    if seconds / 3600 > 0
      case seconds / 3600
      when 1, 21, 31, 41, 5
        if nominative
          result << "#{seconds / 3600} година "
        else
          result << "#{seconds / 3600} годину "
        end
      when 2, 3, 4, 22, 23, 24, 32, 33, 34, 42, 43, 44, 52, 53, 54
        result << "#{seconds / 3600} години "
      else
        result << "#{seconds / 3600} годин "
      end
    end
    if (seconds / 60) % 60 > 0
      case (seconds / 60) % 60
        when 1, 21, 31, 41, 5
          if nominative
            result << "#{(seconds / 60) % 60} хвилина "
          else
            result << "#{(seconds / 60) % 60} хвилину "
          end
        when 2, 3, 4, 22, 23, 24, 32, 33, 34, 42, 43, 44, 52, 53, 54
          result << "#{(seconds / 60) % 60} хвилини "
        else
          result << "#{(seconds / 60) % 60} хвилин "
      end
    end
    if seconds % 60 > 0
      case seconds % 60
        when 1, 21, 31, 41, 5
          if nominative
            result << "#{seconds % 60} секунда"
          else
            result << "#{seconds % 60} секунду"
          end
        when 2, 3, 4, 22, 23, 24, 32, 33, 34, 42, 43, 44, 52, 53, 54
          result << "#{seconds % 60} секунди"
        else
          result << "#{seconds % 60} секунд"
      end
    end
    result
  end

  def block_rule
    result = 'УВАГА!!! Обмеження на ввід: '
    result << "#{@attemts_number} спроб на #{@block_target_id == 0 || @block_target_id == 1 ? 'гравця' : 'команду'} за #{seconds_to_string(attemts_period)}\n\n"
  end

  def load_updated_info(level_json)
    result = ''
    result << task_updated(level_json['Tasks'])
    result << helps_updated(level_json['Helps'])
    result << bonuses_updated(level_json['Bonuses'])
    result << sectors_updated(level_json['Sectors'])
    result << messages_updated(level_json['Messages'])
  end

  def helps_updated(helps_json)
    result = ''
    helps_json.each do |help_json|
      help = @helps.select { |h| h[:id] == help_json['HelpId'] }
      if help.count.zero?
        help = {
            id: help_json['HelpId'],
            number: help_json['Number'],
            text: help_json['HelpText'],
            remains: help_json['RemainSeconds']
        }
        result << help_to_text(help)
      else
        help = help[0]
        if help.text != help_json['HelpText']
          help = {
              id: help_json['HelpId'],
              number: help_json['Number'],
              text: help_json['HelpText'],
              remains: help_json['RemainSeconds']
          }
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
      new_bonus = {
          id: rec['BonusId'],
          name: rec['Name'],
          number: rec['Number'],
          task: rec['Task'],
          help: rec['Help'],
          answered: rec['IsAnswered'],
          expired: rec['Expired'],
          seconds_to_start: rec['SecondsToStart'],
          seconds_left: rec['SecondsLeft'],
          award: rec['AwardTime'],
          answer: rec['Answer'].nil? ? nil : answer(rec['Answer'])
      }
      if bonus[:answered] != new_bonus[:answered] ||
          bonus[:expired] != new_bonus[:expired] ||
          bonus[:task] != new_bonus[:task] ||
          bonus[:help] != new_bonus[:help]
        result << bonus_to_text(new_bonus)
      end
    end
    result
  end

  def sectors_updated(sectors_json)
    result = ''
    sectors_json.each do |rec|
      sectors = @sectors.select { |h| h[:id] == rec['SectorId'] }
      continue if sectors.count.zero?
      sector = sectors[0]
      new_sector = {
        id: rec['SectorId'],
        number: rec['Order'],
        name: rec['Name'],
        answer: rec['Answer'].nil? ? nil : answer(rec['Answer']),
        answered: rec['IsAnswered']
      }
      if sector[:answered] != new_sector[:answered]
        result << sector_to_text(new_sector)
      end
    end
    result
  end

  def messages_updated(messages_json)
    result = ''
    messages_json.each do |message_json|
      message = @messages.select { |h| h[:id] == message_json['MessageId'] }
      if message.count.zero? || message[0][:text] != message_json['MessageText']
        result << "#{message_json['MessageText']}\n\n"
      end
    end
    result
  end

  def task_updated(tasks_json)
    result = ''
    if @task != tasks_json['Tasks'][0]['TaskText']
      result << "#{parsed(tasks_json['Tasks'][0]['TaskText'])}\n\n"
    end
    result
  end

  def parsed(text)
    result = text

    ire = /<img.+?src="\s*(https?:\/\/.+?)\s*".*?>/
    ireA = /<a.+?href=?"(https?:\/\/.+?.(jpg|png|bmp))?".*?>(.*?)<\/a>/

    reBr = /<brs*\/?>/
    reHr = /<hr.*?\/?>/
    reP = /<p>([^ ]+?)<\/p>/
    reBold = /<b.*?\/?>(.+?)<\/b>/
    reStrong = /<strong.*?>(.*?)<\/strong>/
    reItalic = /<i>(.+?)<\/i>/
    reSpan = /<span.*?>(.*?)<\/span>/
    reCenter = /<center>(.+?)<\/center>/
    reFont = /<font.+?colors*=?["«]?#?(w+)?["»]?.*?>(.+?)<\/font>/
    reA = /<a.+?href=?"(.+?)?".*?>(.+?)<\/a>/

    mrBr = result.to_enum(:scan, reBr).map { Regexp.last_match }
    mrBr.each { |match| result.gsub!(match[0], '\n') }
    mrHr = result.to_enum(:scan, reHr).map { Regexp.last_match }
    mrHr.each { |match| result.gsub!(match[0], '\n') }
    mrP = result.to_enum(:scan, reP).map { Regexp.last_match }
    mrP.each { |match| result.gsub!(match[0], "\n#{match[1]}") }
    mrFont = result.to_enum(:scan, reFont).map { Regexp.last_match }
    mrFont.each { |match| result.gsub!(match[0], match[2]) }
    mrBold = result.to_enum(:scan, reBold).map { Regexp.last_match }
    mrBold.each { |match| result.gsub!(match[0], "*#{match[1]}*") }
    mrStrong = result.to_enum(:scan, reStrong).map { Regexp.last_match }
    mrStrong.each { |match| result.gsub!(match[0], "*#{match[1]}*") }
    mrItalic = result.to_enum(:scan, reItalic).map { Regexp.last_match }
    mrItalic.each { |match| result.gsub!(match[0], "_#{match[1]}_") }
    mrSpan = result.to_enum(:scan, reSpan).map { Regexp.last_match }
    mrSpan.each { |match| result.gsub!(match[0], match[1]) }
    mrCenter = result.to_enum(:scan, reCenter).map { Regexp.last_match }
    mrCenter.each { |match| result.gsub!(match[0], match[1]) }
    mre = result.to_enum(:scan, ire).map { Regexp.last_match }
    mre.each { |match| result.gsub!(match[0], match[1]) }
    # mreA = result.to_enum(:scan, ireA).map { Regexp.last_match }
    # mreA.each { |match| result.gsub!(match[0], "[#{match[2]}](#{match[1]})") }
    mrA = result.to_enum(:scan, reA).map { Regexp.last_match }
    mrA.each { |match| result.gsub!(match[0], "[#{match[2]}](#{match[1]})") }
    result
  end
end