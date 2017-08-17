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

  def full_level_info
    result = "*Рівень #{@number} із #{@levels_count}*"
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
      result << "\n#{parsed(help[:text])}\n\n" unless help[:text].nil?
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
    unless bonus[:task].nil? || bonus[:task].empty? || bonus[:answered]
      result << "*Завдання*: #{parsed(bonus[:task])}\n"
    end
    unless bonus[:help].nil? || bonus[:help].empty?
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

  def load_updated_info(level_json, with_q_time = false)
    result = ''
    if with_q_time && level_json['TimeoutSecondsRemain'] > 0
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
      if help.empty?
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
        result << "#{parser(message_json['MessageText'])}\n\n"
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

    ire = %r{<img.+?src="\s*(https?://.+?)\s*".*?>}
    # ireA = /<a.+?href=?"(https?:\/\/.+?.(jpg|png|bmp))?".*?>(.*?)<\/a>/

    reBr = %r{</*br\s*/?>}
    reHr = %r{<hr.*?/?>}
    reP = %r{<p>([^ ]+?)</p>}
    reBold = %r{<b.*?/?>(.+?)</b>}
    reStrong = %r{<strong.*?>(.*?)</strong>}
    reItalic = %r{<i>(.+?)</i>}
    reStyle = %r{<style.*?>([\s\S.]*?)</style>}
    reScript = %r{<script.*?>([\s\S.]*?)</script>}
    reSpan = %r{<span.*?>([\s\S.]*?)</span>}
    reCenter = %r{<center>(.+?)</center>}
    reFont = %r{<font.+?colors*=?["«]?#?(w+)?["»]?.*?>([\s\S.]+?)</font>}
    reA = %r{<a.+?href=?"(.+?)?".*?>(.+?)</a>}
    reTable = %r{<table.*?>([\s\S.]*?)</table>}
    reTr = %r{<tr.*?>([\s\S.]*?)</tr>}
    reTd = %r{<td.*?>([\s\S.]*?)</td>}

    # <a href="geo:49.976136, 36.267256">49.976136, 36.267256</a>
    geoHrefRe = %r{<a.+?href="geo:(\d{2}[.,]\d{3,}),?\s*(\d{2}[.,]\d{3,})">(.+?)</a>}
    # <a href="https://www.google.com.ua/maps/@50.0363257,36.2120039,19z" target="blank">50.036435 36.211914</a>
		hrefRe = %r{<a.+?href="https?://.+?(\d{2}[.,]\d{3,}),?\s*(\d{2}[.,]\d{3,}).*?">(.+?)</a>}
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
    mrTd = result.to_enum(:scan, reTd).map { Regexp.last_match }
    mrTd.each { |match| result = result.gsub(match[0], "#{match[1]} : ") }
    mrTr = result.to_enum(:scan, reTr).map { Regexp.last_match }
    mrTr.each { |match| result = result.gsub(match[0], "#{match[1]}\n") }
    mrTable = result.to_enum(:scan, reTable).map { Regexp.last_match }
    mrTable.each { |match| result = result.gsub(match[0], match[1]) }
    result = result.gsub('&nbsp;', ' ')
    result = result.gsub("\r", '')
    result = result.gsub("\n\n\n", "\n\n")
    result
  end

  def google_link(lat, lon)
    "http://maps.google.com/maps?daddr=#{lat},#{lon}&saddr=My+Location"
  end
end