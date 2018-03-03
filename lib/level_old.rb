class Level
  attr_reader :id, :number, :has_answer_block_rule
  attr_accessor :coords, :notified

  def initialize(level_json)
    @coords = []
    load_level_from_json(level_json)
    @notified = false
  end

  def full_info(level_json, by_timer = false)
    @coords = []
    load_level_from_json(level_json)
    { text: full_level_info(by_timer), coords: coords }
  end

  def updated_info(level_json, with_q_time = false, block_sector = false, notify_before = 5)
    @coords = []
    if level_json['Level']['LevelId'] != @id
      full_info(level_json, !with_q_time)
    else
      result = load_updated_info(level_json['Level'], with_q_time, block_sector, notify_before)
      update_level_from_json(level_json)
      { text: result, coords: coords }
    end
  end

  def needed_sectors(level_json)
    @coords = []
    load_level_from_json(level_json)
    return nil if @sectors.count < 2
    result = "Лишилось закрити *#{@sectors_left_to_close}*.\nНезакриті сектори:\n"
    @sectors.each do |sector|
      result << "#{sector[:name]}\n" unless sector[:answered]
    end
    { text: result, coords: coords }
  end

  def all_sectors(level_json)
    @coords = []
    load_level_from_json(level_json)
    return nil if @sectors.count < 2
    result = "Лишилось закрити *#{@sectors_left_to_close}*.\nCектори:\n"
    @sectors.each do |sector|
      result << "#{sector[:name]}: #{sector[:answered] ? sector[:answer][:answer] : '-'}\n"
    end
    { text: result, coords: coords }
  end

  def all_bonuses(level_json)
    @coords = []
    load_level_from_json(level_json)
    return nil if @sectors.count.zero?
    result = ''
    @bonuses.each { |bonus| result << bonus_to_text(bonus) }
    { text: result, coords: coords }
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
    unless Array(level_json['Tasks']).empty?
      @task = level_json['Tasks'][0]['TaskText']
    end
    @messages = Array(level_json['Messages']).map { |rec| json_to_message(rec) }
    @sectors = Array(level_json['Sectors']).map { |rec| json_to_sector(rec) }
    @helps = Array(level_json['Helps']).map { |rec| json_to_help(rec) }
    @penalty_helps = Array(level_json['PenaltyHelps']).map do |rec|
      json_to_penalty_help(rec)
    end
    @bonuses = Array(level_json['Bonuses']).map { |rec| json_to_bonus(rec) }
  end

  def update_level_from_json(level_json)
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
    unless Array(level_json['Tasks']).empty?
      @task = level_json['Tasks'][0]['TaskText']
    end
    @messages = Array(level_json['Messages']).map { |rec| json_to_message(rec) }
    @sectors = Array(level_json['Sectors']).map { |rec| json_to_sector(rec) }
    @helps = Array(level_json['Helps']).map { |rec| json_to_help(rec) }
    @penalty_helps = Array(level_json['PenaltyHelps']).map do |rec|
      json_to_penalty_help(rec)
    end
    @bonuses = Array(level_json['Bonuses']).map { |rec| json_to_bonus(rec) }
  end

  def answer(rec)
    { answer: rec['Answer'], user: rec['Login'] }
  end

  def full_level_info(by_timer = false)
    result = ''
    result << "\xE2\x80\xBC *UP* \xE2\x80\xBC\n\n" if by_timer
    result << "*Рівень #{@number} із #{@levels_count}*"
    result << "#{": #{parsed(@name)}" unless @name.nil? || @name.empty?}\n\n"
    if @timeout_seconds_remain > 0
      result << "*Автоперехід* через *#{seconds_to_string(@timeout_seconds_remain)}*\n\n"
    end
    result << block_rule if @has_answer_block_rule
    result << parsed(@task)
    result << "\n\n"
    unless @sectors.empty?
      result << "Треба закрити *#{@sectors_left_to_close}* секторів із *#{@sectors.count}*\n\n"
    end
    @helps.each { |help| result << help_to_text(help) }
    result << "\n" unless @helps.empty?
    @penalty_helps.each { |help| result << penalty_help_to_text(help) }
    result << "\n" unless @penalty_helps.empty?
    @bonuses.each { |bonus| result << bonus_to_text(bonus) }
    result << "\n" unless @bonuses.empty?
    @messages.each do |el|
      result << "*Повідомлення* від *#{parsed(el[:owner])}*: #{parsed(el[:text])}\n\n"
    end
    result
  end

  def help_to_text(help)
    result = "*Підказка #{help[:number]}*: "
    if help[:remains].zero?
      result << "\n#{parsed(help[:text])}\n\n"
    else
      result << "буде через *#{seconds_to_string(help[:remains])}*\n\n"
    end
    result
  end

  def penalty_help_to_text(help)
    result = "*Штрафна підказка #{help[:number]}*: "
    if help[:remains].zero?
      result << "\n*Опис*: #{parsed(help[:comment])}" unless help[:comment].nil? || help[:comment] == ''
      result << "\n*Підказка*: #{parsed(help[:text])}" unless help[:text].nil? || help[:text] == ''
      result << "\n*Штраф*: #{seconds_to_string(help[:penalty])}\n\n"
    else
      result << "буде через *#{seconds_to_string(help[:remains])}*\n\n"
    end
    result
  end

  def bonus_to_text(bonus)
    result = "*Бонус #{bonus[:number]}*"
    unless bonus[:name].nil? || bonus[:name].empty? || (bonus[:number].to_s == bonus[:name])
      result << " *#{parsed(bonus[:name])}*"
    end
    result << ':'
    if bonus[:seconds_to_start] > 0
      result << "буде доступний через *#{seconds_to_string(bonus[:seconds_to_start])}*\n"
    end
    if bonus[:seconds_left] > 0
      result << "закриється через *#{seconds_to_string(bonus[:seconds_left])}*\n"
    end
    if bonus[:answered]
      result << "закрито кодом *#{parsed(bonus[:answer][:answer])}*\n"
    end
    result << "не закрито\n" if bonus[:expired]
    unless bonus[:task].nil? || parsed(bonus[:task]).empty? || bonus[:answered]
      result << "*Завдання*: #{parsed(bonus[:task])}\n"
    end
    unless bonus[:help].nil? || parsed(bonus[:help]).strip.empty?
      result << "*Підказка*: #{parsed(bonus[:help])}\n"
    end
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

  def load_updated_info(level_json, with_q_time = false, block_sector = false, notify_before = 5)
    result = ''
    if level_json['TimeoutSecondsRemain'] > 0
      if with_q_time
        result << '*Автоперехід* через '
        result << "*#{seconds_to_string(level_json['TimeoutSecondsRemain'])}*\n\n"
      elsif notify_before > (level_json['TimeoutSecondsRemain'] / 60) && !notified
        @notified = true
        result << '*Автоперехід* через '
        result << "*#{seconds_to_string(level_json['TimeoutSecondsRemain'])}*\n\n"
      end
    end
    result << task_updated(level_json['Tasks'])
    result << helps_updated(level_json['Helps'], notify_before)
    result << penalty_helps_updated(level_json['PenaltyHelps'])
    result << bonuses_updated(level_json['Bonuses']) unless block_sector
    result << sectors_updated(level_json['Sectors']) unless block_sector
    result << messages_updated(level_json['Messages'])
    result
  end

  def helps_updated(helps_json, notify_before = 5)
    result = ''
    helps_json.each do |help_json|
      help = @helps.select { |h| h[:id] == help_json['HelpId'] }
      if help.empty?
        help = json_to_help(help_json)
        result << help_to_text(help)
      else
        help = help[0]
        if !help[:notified] && notify_before > help_json['RemainSeconds'] * 60
          help[:notified] = true
          updated_help = json_to_help(help_json)
          result << help_to_text(updated_help)
        end
        if help[:text] != help_json['HelpText']
          help = json_to_help(help_json)
          result << help_to_text(help)
        end
      end
    end
    result
  end

  def penalty_helps_updated(helps_json)
    result = ''
    helps_json.each do |help_json|
      help = @penalty_helps.select { |h| h[:id] == help_json['HelpId'] }
      if help.empty?
        help = json_to_penalty_help(help_json)
        result << penalty_help_to_text(help)
      else
        help = help[0]
        if help_json['RemainSeconds'].zero? && (help[:comment] != help_json['PenaltyComment'] || help[:message] != help_json['PenaltyMessage'])
          help = json_to_penalty_help(help_json)
          result << penalty_help_to_text(help)
        end
      end
    end
    result
  end

  def bonuses_updated(bonuses_json)
    result = ''
    bonuses_json.each do |rec|
      bonuses = @bonuses.select { |h| h[:id] == rec['BonusId'] }
      next if bonuses.empty?
      bonus = bonuses[0]
      new_bonus = json_to_bonus(rec)
      next if bonuses_identical?(bonus, new_bonus)
      result << bonus_to_text(new_bonus)
    end
    result
  end

  def bonuses_identical?(bonus1, bonus2)
    bonus1[:answered] == bonus2[:answered] &&
      bonus1[:expired] == bonus2[:expired] &&
      bonus1[:task] == bonus2[:task] &&
      bonus1[:help] == bonus2[:help]
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
      id: help_json['HelpId'],
      number: help_json['Number'],
      text: help_json['HelpText'],
      message: help_json['PenaltyMessage'],
      remains: help_json['RemainSeconds'],
      penalty: help_json['Penalty'],
      comment: help_json['PenaltyComment'],
      state: help_json['PenaltyHelpState']
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
      next if sectors.empty?
      sector = sectors[0]
      new_sector = json_to_sector(rec)
      if sector[:answered] != new_sector[:answered]
        result << sector_to_text(new_sector)
      end
    end
    result
  end

  def sector_to_text(sector)
    "Сектор *#{parsed(sector[:name])}* закрито кодом *#{parsed(sector[:answer][:answer])}*\n"
  end

  def messages_updated(messages_json)
    result = ''
    messages_json.each do |message_json|
      message = @messages.select { |h| h[:id] == message_json['MessageId'] }
      if message.empty? || message[0][:text] != message_json['MessageText']
        result << "*Повідомлення* від *#{parsed(message_json['OwnerLogin'])}*: "
        result << "#{parsed(message_json['MessageText'])}\n\n"
      end
    end
    result
  end

  def task_updated(tasks_json)
    result = ''
    if tasks_json.count > 0 && @task != tasks_json[0]['TaskText']
      result << "#{parsed(tasks_json[0]['TaskText'])}\n\n"
    end
    result
  end

  def parsed(text)
    result = text

    ire = %r{<img.+?src="\s*(https?://.+?)\s*".*?>}
    ireA = /<a.+?href=?"(https?:\/\/.+?.(jpg|png|bmp))?".*?>(.*?)<\/a>/

    reBr = %r{</*br\s*/?>}
    reHr = %r{<hr.*?/?>}
    reP = %r{<p>([\s\S.]+?)</p>}
    reBold = %r{<b.*?/?>([\s\S.]+?)</b>}
    reStrong = %r{<strong.*?>([\s\S.]*?)</strong>}
    reItalic = %r{<i>([\s\S.]+?)</i>}
    reStyle = %r{<style.*?>([\s\S.]*?)</style>}
    reScript = %r{<script.*?>([\s\S.]*?)</script>}
    reSpan = %r{<span.*?>([\s\S.]*?)</span>}
    reCenter = %r{<center>([\s\S.]+?)</center>}
    reFont = %r{<font.+?colors*=?["«]?#?(w+)?["»]?.*?>([\s\S.]+?)</font>}
    reA = %r{<a.+?href=?"(.+?)?".*?>(.+?)</a>}
    reTable = %r{<table.*?>([\s\S.]*?)</table>}
    reTr = %r{<tr.*?>([\s\S.]*?)</tr>}
    reTd = %r{<td.*?>([\s\S.]*?)</td>}


    # <a href="https://www.google.com.ua/maps/place/50%C2%B044'33.4%22N+25%C2%B028'26.2%22E/@50.7407788,25.4743992,378m/data=!3m1!1e3!4m5!3m4!1s0x0:0x0!8m2!3d50.7426!4d25.473939?hl=uk" target="blank">50.742600,25.473939</a>
    # <a href="geo:49.976136, 36.267256">49.976136, 36.267256</a>
    geoHrefRe = %r{<a.+?href="geo:(\d{1,3}[.,]\d{3,}),?\s*(-*\d{1,2}[.,]\d{3,})">(.+?)</a>}

    # <a href="https://www.google.com.ua/maps/@50.0363257,36.2120039,19z" target="blank">50.036435 36.211914</a>
		hrefRe = %r{<a.+?href="https?://.+?(\d{1,3}[.,]\d{3,}),?\s*(-*\d{1,2}[.,]\d{3,}).*?">(.+?)</a>}

    # 49.976136, 36.267256
    numbersRe = /(\d{1,3}[.,]\d{3,}),?\s*(-*\d{1,2}[.,]\d{3,})/


    mrStyle = result.to_enum(:scan, reStyle).map { Regexp.last_match }
    mrStyle.each { |match| result = result.gsub(match[0], '') }

    mrScript = result.to_enum(:scan, reScript).map { Regexp.last_match }
    mrScript.each { |match| result = result.gsub(match[0], '') }
    result = result.gsub("_", "\\_").gsub("*", "\\*")

    mrFont = result.to_enum(:scan, reFont).map { Regexp.last_match }
    mrFont.each { |match| result = result.gsub(match[0], match[2]) }

    mrBold = result.to_enum(:scan, reBold).map { Regexp.last_match }
    mrBold.each { |match| result = result.gsub(match[0], "*#{match[1]}*") }

    mrStrong = result.to_enum(:scan, reStrong).map { Regexp.last_match }
    mrStrong.each { |match| result = result.gsub(match[0], "*#{match[1]}*") }

    mrItalic = result.to_enum(:scan, reItalic).map { Regexp.last_match }
    mrItalic.each { |match| result = result.gsub(match[0], "#{match[1]}") }

    mrGeoHrefRe = result.to_enum(:scan, geoHrefRe).map { Regexp.last_match }
    mrGeoHrefRe.each do |match|
      result = result.gsub(match[0], "#{match[1]}, #{match[2]}")
      unless @coords.any? { |coord| coord[:latitude] == match[1] && coord[:longitude] == match[2] }
        @coords << { latitude: match[1], longitude: match[2], name: match[3] }
      end
    end

    mrHrefRe = result.to_enum(:scan, hrefRe).map { Regexp.last_match }
    mrHrefRe.each do |match|
      result = result.gsub(match[0], "#{match[1]}, #{match[2]}")
      unless @coords.any? { |coord| coord[:latitude] == match[1] && coord[:longitude] == match[2] }
        @coords << { latitude: match[1], longitude: match[2], name: match[3] }
      end
    end

    mrNumbersRe = result.to_enum(:scan, numbersRe).map { Regexp.last_match }
    mrNumbersRe.each do |match|
      # result = result.gsub(
      #   # match[0],
      #   # "[#{match[1]} #{match[2]}] (#{google_link(match[1], match[2])})"
      # )
      unless @coords.any? { |coord| coord[:latitude] == match[1] && coord[:longitude] == match[2] }
        @coords << { latitude: match[1], longitude: match[2], name: "#{match[1]}, #{match[2]}" }
      end
    end

    mrSpan = result.to_enum(:scan, reSpan).map { Regexp.last_match }
    mrSpan.each { |match| result = result.gsub(match[0], match[1]) }

    mrCenter = result.to_enum(:scan, reCenter).map { Regexp.last_match }
    mrCenter.each { |match| result = result.gsub(match[0], match[1]) }

    mre = result.to_enum(:scan, ire).map { Regexp.last_match }
    mre.each { |match| result = result.gsub(match[0], match[1]) }

    mreA = result.to_enum(:scan, ireA).map { Regexp.last_match }
    mreA.each { |match| result.gsub!(match[0], match[1]) }

    mrA = result.to_enum(:scan, reA).map { Regexp.last_match }
    mrA.each { |match| result = result.gsub(match[0], "[#{match[2]}](#{match[1]})") }

    mrP = result.to_enum(:scan, reP).map { Regexp.last_match }
    mrP.each { |match| result = result.gsub(match[0], "\n#{match[1]}") }

    mrBr = result.to_enum(:scan, reBr).map { Regexp.last_match }
    mrBr.each { |match| result = result.gsub(match[0], "\n") }

    mrHr = result.to_enum(:scan, reHr).map { Regexp.last_match }
    mrHr.each { |match| result = result.gsub(match[0], "\n") }

    mrTd = result.to_enum(:scan, reTd).map { Regexp.last_match }
    mrTd.each { |match| result = result.gsub(match[0], "#{match[1]} : ") }

    mrTr = result.to_enum(:scan, reTr).map { Regexp.last_match }
    mrTr.each { |match| result = result.gsub(match[0], "#{match[1]}\n") }

    mrTable = result.to_enum(:scan, reTable).map { Regexp.last_match }
    mrTable.each { |match| result = result.gsub(match[0], match[1]) }

    result = result.gsub('&nbsp;', ' ')
    result = result.gsub("\r", '')
    result.gsub("\n\n\n", "\n\n")
  end

  def google_link(lat, lon)
    "https://www.google.com/maps?q=#{lat},#{lon}"
  end
end