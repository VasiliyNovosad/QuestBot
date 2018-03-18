require_relative '../lib/task'
require_relative '../lib/sector'
require_relative '../lib/bonus'
require_relative '../lib/help'
require_relative '../lib/penalty_help'
require_relative '../lib/message'
require_relative '../lib/bot_utils'

class Level
  include BotUtils
  attr_accessor :id, :number, :has_answer_block_rule, :block_duration, :block_target_id, :attemts_number,
                :attemts_period, :coords, :notified, :name, :timeout_seconds_remain, :required_sectors_count,
                :passed_sectors_count, :sectors_left_to_close, :task, :helps, :penalty_helps, :sectors,
                :bonuses, :messages, :notified, :levels_count

  def initialize(level_json, notify_before = 5)
    @coords = []
    levels = level_json['Levels']
    @levels_count = levels.nil? ? 0 : levels.count
    @notified = false
    from_json(level_json['Level'] || {}, notify_before)
  end

  def full_info(level_json, by_timer = false, notify_before = 5)
    @coords = []
    levels = level_json['Levels']
    @levels_count = levels.nil? ? 0 : levels.count
    from_json(level_json['Level'] || {}, notify_before)
    { text: to_text(by_timer), coords: coords }
  end

  def updated_info(level_json, with_q_time = false, block_sector = false, notify_before = 5)
    @coords = []
    if level_json['Level']['LevelId'] != @id
      full_info(level_json, !with_q_time, notify_before)
    else
      levels = level_json['Levels']
      @levels_count = levels.nil? ? 0 : levels.count
      result = load_updated_info(level_json['Level'], with_q_time, block_sector, notify_before)
      update_from_json(level_json['Level'])
      { text: result, coords: coords }
    end
  end

  def needed_sectors(level_json)
    @coords = []
    update_from_json(level_json['Level'])
    return nil if @sectors.count < 2
    result = "Лишилось закрити *#{@sectors_left_to_close}*.\nНезакриті сектори:\n"
    @sectors.each do |_, sector|
      result << "#{parsed(sector.name)[:text]}\n" unless sector.is_answered
    end
    { text: result, coords: coords }
  end

  def all_sectors(level_json)
    @coords = []
    update_from_json(level_json['Level'])
    return nil if @sectors.count < 2
    result = "Лишилось закрити *#{@sectors_left_to_close}*.\nCектори:\n"
    @sectors.each do |_, sector|
      result << "#{parsed(sector.name)[:text]}: #{sector.is_answered ? parsed(sector.answer)[:text] : '-'}\n"
    end
    { text: result, coords: coords }
  end

  def all_bonuses(level_json)
    @coords = []
    update_from_json(level_json['Level'])
    return nil if @sectors.count.zero?
    result = ''
    @bonuses.each { |bonus| result << bonus.to_text }
    { text: result, coords: coords }
  end

  def all_coords
    all_coords = {}
    all_coords["#{number}"] = task.coords if task.coords.length > 0
    helps.each do |id, help|
      all_coords["#{number}. Підказка #{help.number}"] = help.coords if help.coords.length > 0
    end
    penalty_helps.each do |id, help|
      all_coords["#{number}. Штрафна підказка #{help.number}"] = help.coords if help.coords.length > 0
    end
    bonuses.each do |id, bonus|
      all_coords["#{number}. Бонус #{bonus.number}: #{bonus.name}"] = bonus.coords if bonus.coords.length > 0
    end
    messages.each do |id, message|
      all_coords["#{number}. Повідомлення #{message.id} від #{message.owner_login}"] = message.coords if message.coords.length > 0
    end
    all_coords
  end

  private

  def from_json(level_json, notify_before = 5)
    @id = level_json['LevelId']
    @name = level_json['Name']
    @number = level_json['Number']
    @timeout_seconds_remain = level_json['TimeoutSecondsRemain']
    @notified = (level_json['TimeoutSecondsRemain'] || 100000) < notify_before * 60
    @has_answer_block_rule = level_json['HasAnswerBlockRule']
    @block_duration = level_json['BlockDuration']
    @block_target_id = level_json['BlockTargetId']
    @attemts_number = level_json['AttemtsNumber']
    @attemts_period = level_json['AttemtsPeriod']
    @required_sectors_count = level_json['RequiredSectorsCount']
    @passed_sectors_count = level_json['PassedSectorsCount']
    @sectors_left_to_close = level_json['SectorsLeftToClose']
    @task = nil
    unless Array(level_json['Tasks']).length == 0
      @task = Task.from_json(level_json['Tasks'][0])
    end
    @messages = {}
    Array(level_json['Messages']).each do |message_json|
      @messages[message_json['MessageId']] = Message.from_json(message_json)
    end
    @sectors = {}
    Array(level_json['Sectors']).each do |sector_json|
      @sectors[sector_json['SectorId']] = Sector.from_json(sector_json)
    end
    @helps = {}
    Array(level_json['Helps']).each do |help_json|
      new_help = Help.from_json(help_json)
      new_help.notified = new_help.remain_seconds < 60 * notify_before
      @helps[help_json['HelpId']] = new_help
    end
    @penalty_helps = {}
    Array(level_json['PenaltyHelps']).each do |help_json|
      @penalty_helps[help_json['HelpId']] = PenaltyHelp.from_json(help_json)
    end
    @bonuses = {}
    Array(level_json['Bonuses']).each do |bonus_json|
      @bonuses[bonus_json['BonusId']] = Bonus.from_json(bonus_json)
    end
  end

  def update_from_json(level_json)
    @name = level_json['Name']
    @number = level_json['Number']
    @timeout_seconds_remain = level_json['TimeoutSecondsRemain'] || 0
    @has_answer_block_rule = level_json['HasAnswerBlockRule']
    @block_duration = level_json['BlockDuration']
    @block_target_id = level_json['BlockTargetId']
    @attemts_number = level_json['AttemtsNumber']
    @attemts_period = level_json['AttemtsPeriod']
    @required_sectors_count = level_json['RequiredSectorsCount']
    @passed_sectors_count = level_json['PassedSectorsCount']
    @sectors_left_to_close = level_json['SectorsLeftToClose']
    unless level_json['Tasks'].length == 0
      @task.from_json(level_json['Tasks'][0])
    end
    level_json['Messages'].each do |message_json|
      message = @messages[message_json['MessageId']]
      if message.nil?
        message = Message.from_json(message_json)
      else
        message.from_json(message_json)
      end
      @messages[message_json['MessageId']] = message
    end
    level_json['Sectors'].each do |sector_json|
      sector = @sectors[sector_json['SectorId']]
      if sector.nil?
        sector = Sector.from_json(sector_json)
      else
        sector.from_json(sector_json)
      end
      @sectors[sector_json['SectorId']] = sector
    end
    level_json['Helps'].each do |help_json|
      help = @helps[help_json['HelpId']]
      if help.nil?
        help = Help.from_json(help_json)
      else
        help.from_json(help_json)
      end
      @helps[help_json['HelpId']] = help
    end
    level_json['PenaltyHelps'].each do |help_json|
      help = @penalty_helps[help_json['HelpId']]
      if help.nil?
        help = Help.from_json(help_json)
      else
        help.from_json(help_json)
      end
      @penalty_helps[help_json['HelpId']] = help
    end
    level_json['Bonuses'].each do |bonus_json|
      bonus = @bonuses[bonus_json['HelpId']]
      if bonus.nil?
        bonus = Bonus.from_json(bonus_json)
      else
        bonus.from_json(bonus_json)
      end
      @bonuses[bonus_json['BonusId']] = bonus
    end
  end

  def to_text(by_timer = false)
    result = ''
    result << "\xE2\x80\xBC *UP* \xE2\x80\xBC\n\n" if by_timer
    result << "*Рівень #{number} із #{levels_count}*"
    result << "#{": #{parsed(name)[:text]}" unless name.nil? || name.empty?}\n\n"
    if (timeout_seconds_remain || 0) > 0
      result << "*Автоперехід* через *#{seconds_to_string(timeout_seconds_remain || 0)}*\n\n"
    end
    result << block_rule if has_answer_block_rule
    result << task.to_text
    @coords += task.coords
    result << "\n\n"
    unless sectors.empty?
      result << "Треба закрити *#{sectors_left_to_close}* секторів із *#{sectors.count}*\n\n"
    end
    helps.each do |_, help|
      result << help.to_text
      @coords += help.coords
    end
    result << "\n" unless helps.empty?
    penalty_helps.each do |_, help|
      result << help.to_text
      @coords += help.coords
    end
    result << "\n" unless penalty_helps.empty?
    bonuses.each do |_, bonus|
      result << bonus.to_text
      @coords += bonus.coords
    end
    result << "\n" unless bonuses.empty?
    messages.each do |_, message|
      result << message.to_text
      @coords += message.coords
    end
    result
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
      elsif notify_before * 60 > level_json['TimeoutSecondsRemain'] && !notified
        @notified = true
        result << '*Автоперехід* через '
        result << "*#{seconds_to_string(level_json['TimeoutSecondsRemain'])}*\n\n"
      end
    end
    result << task_updated(level_json['Tasks'])
    result << helps_updated(level_json['Helps'], notify_before)
    result << penalty_helps_updated(level_json['PenaltyHelps'])
    bonus_updated = bonuses_updated(level_json['Bonuses'])
    result << bonus_updated unless block_sector
    sector_updated = sectors_updated(level_json['Sectors'])
    result << sector_updated unless block_sector
    result << messages_updated(level_json['Messages'])
    result
  end

  def helps_updated(helps_json, notify_before = 5)
    result = ''
    helps_json.each do |help_json|
      new_help = Help.from_json(help_json)
      help = @helps[new_help.id]
      if help.nil?
        result << new_help.to_text
        new_help.notified = new_help.remain_seconds < notify_before * 60
        @coords += new_help.coords
        @helps[new_help.id] = new_help
      else
        if !help.notified && new_help.remain_seconds < notify_before * 60
          @helps[new_help.id].notified = true
          result << new_help.to_text
          @coords += new_help.coords
        end
        unless @helps[new_help.id] == new_help
          result << new_help.to_text
          @coords += new_help.coords
        end
      end
    end
    result
  end

  def penalty_helps_updated(helps_json)
    result = ''
    helps_json.each do |help_json|
      new_help = PenaltyHelp.from_json(help_json)
      help = @penalty_helps[new_help.id]
      if help.nil? || help != new_help
        result << new_help.to_text
        @coords += new_help.coords
      end
    end
    result
  end

  def bonuses_updated(bonuses_json)
    result = ''
    bonuses_json.each do |bonus_json|
      new_bonus = Bonus.from_json(bonus_json)
      bonus = @bonuses[new_bonus.id]
      if bonus.nil? || bonus != new_bonus
        result << new_bonus.to_text
        @coords += new_bonus.coords
      end
    end
    result
  end

  def sectors_updated(sectors_json)
    result = ''
    sectors_json.each do |sector_json|
      new_sector = Sector.from_json(sector_json)
      sector = @sectors[new_sector.id]
      if sector.nil? || sector != new_sector
        result << new_sector.to_text
      end
    end
    result
  end

  def messages_updated(messages_json)
    result = ''
    messages_json.each do |message_json|
      new_message = Message.from_json(message_json)
      message = @messages[new_message.id]
      if message.nil? || message != new_message
        result << new_message.to_text
        @coords += new_message.coords
      end
    end
    result
  end

  def task_updated(tasks_json)
    result = ''
    if tasks_json.count > 0
      new_task = Task.from_json(tasks_json[0])
      unless @task == new_task
        result << new_task.to_text
        @coords += new_task.coords
      end
    end
    result
  end

  def google_link(lat, lon)
    "https://www.google.com/maps?q=#{lat},#{lon}"
  end
end