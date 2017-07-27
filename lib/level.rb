class Level
  def initialize(level_json)
    load_level_from_json(level_json)
  end

  def full_info(level_json)
    load_level_from_json(level_json)
  end

  def updated_info(level_json)
    load_level_from_json(level_json)
  end

  def needed_sectors(level_json)
    load_level_from_json(level_json)
  end

  def all_sectors(level_json)
    load_level_from_json(level_json)
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
        owner: rec['OwnerLogin'],
        text: rec['MessageText']
      }
    end
    @sectors = level_json['Sectors'].map do |rec|
      {
        number: rec['Order'],
        name: rec['Name'],
        answer: rec['Answer'].nil? ? nil : answer(rec['Answer']),
        answered: rec['IsAnswered']
      }
    end
    @helps = level_json['Helps'].map do |rec|
      {
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
    result << @task
    result << '\n\n'
    @helps.each { |help| result << help_to_text(help) }
    result << '\n\n'
    @penalty_helps.each { |help| result << penalty_help_to_text(help) }
    result << '\n\n'
    result << '\n\n'
    result << '\n\n'
    result << '\n\n'

  end

  def help_to_text(help)
    result = "Підказка #{help[:number]}: "
    result << help[:remains].zero? ? help[:text] : "буде через #{help[:remains]} секунд\n\n"
    result
  end

  def penalty_help_to_text(help)
    result = "Штрафна підказка #{help[:number]}: "
    result << help[:remains].zero? ? help[:text] : "буде через #{help[:remains]} секунд\n\n"
    result
  end
end