# {
#     "BonusId": 938451,
#     "Name": "Классная комната. Гульнара Раджибулаевна(5 ванечков)",
#     "Number": 1,
#     "Task": "Ищите классную комнату с доской (Выходим из большого зала через центральный вход и фойе в главный коридор и бежим направо. По правой стороне будет \"классная комната\"). В этой комнате вас будет ждать учительница русского языка в вашей колонии - Гульнара Раджибулаевна. \r\n\r\nСтрого выполняйте ее указания.\r\n\r\nФормат ответа: слово",
#     "Help": "Фраза: \"Руссо пониманса, учила обниманса\" \u003cscript\u003e $( document ).ready(function() { $(\u0027#result\u0027).text( parseInt($(\u0027#result\u0027).text())+5); var width = parseFloat($(\u0027.line-value\u0027).css(\u0027width\u0027)); var parent_width = parseFloat($(\u0027.line-value\u0027).parent().css(\u0027width\u0027)); $(\u0027.line-value\u0027).width(width + parent_width*0.05); var left_value = parseFloat($(\u0027.value\u0027).position().left); $(\u0027.value\u0027).css({left: (left_value + parseInt($(\u0027.value\u0027).width())*0.5 + parent_width*0.05)}); })\u003c/script\u003e",
#     "IsAnswered": true,
#     "Expired": false,
#     "SecondsToStart": 0,
#     "SecondsLeft": 0,
#     "AwardTime": 0,
#     "Answer": {
#         "Answer": "Ирис",
#         "AnswerDateTime": {
#             "Value": 63642995749747
#         },
#         "Login": "Mishytka",
#         "UserId": 69789
#     }
# }
require_relative '../lib/bot_utils'

class Bonus
  include BotUtils
  attr_accessor :id, :name, :number, :task, :help, :answer, :is_answered, :expired, :seconds_to_start, :seconds_left, :award_time, :coords

  def initialize(id, name, number, task, help, answer, is_answered, expired, seconds_to_start, seconds_left, award_time)
    @id = id
    @name = name
    @number = number
    @task = task
    @help = help
    @answer = answer
    @is_answered = is_answered
    @expired = expired
    @seconds_to_start = seconds_to_start
    @seconds_left = seconds_left
    @award_time = award_time
    @coords = []
  end

  def self.from_json(bonus_json)
    @name = bonus_json['Name']
    @number = bonus_json['Number']
    @task = bonus_json['Task']
    @help = bonus_json['Help']
    @answer = bonus_json['IsAnswered'] ? bonus_json['Answer']['Answer'] : nil
    @is_answered = bonus_json['IsAnswered']
    @expired = bonus_json['Expired']
    @seconds_to_start = bonus_json['SecondsToStart']
    @seconds_left = bonus_json['SecondsLeft']
    @award_time = bonus_json['AwardTime']
  end

  def from_json(bonus_json)
    Bonus.new(
        bonus_json['BonusId'],
        bonus_json['Name'],
        bonus_json['Number'],
        bonus_json['Task'],
        bonus_json['Help'],
        bonus_json['IsAnswered'] ? bonus_json['Answer']['Answer'] : nil,
        bonus_json['IsAnswered'],
        bonus_json['Expired'],
        bonus_json['SecondsToStart'],
        bonus_json['SecondsLeft'],
        bonus_json['AwardTime']
    )
  end

  def ==(other_object)
    other_object.class == self.class &&
      id == other_object.id &&
      name == other_object.name &&
      task == other_object.task &&
      help == other_object.help &&
      answer == other_object.answer &&
      is_answered == other_object.is_answered &&
      expired == other_object.expired
  end

  def to_text
    result = "*Бонус #{number}*"
    all_coords = []
    unless name.nil? || name.empty? || (number.to_s == name)
      result << " *#{parsed(name)[:text]}*"
    end
    result << ':'
    if seconds_to_start > 0
      result << "буде доступний через *#{seconds_to_string(seconds_to_start)}*\n"
    end
    if seconds_left > 0
      result << "закриється через *#{seconds_to_string(seconds_left)}*\n"
    end
    if is_answered
      result << "закрито кодом *#{parsed(answer)[:text]}*\n"
    end
    result << "не закрито\n" if expired
    unless task.nil? || is_answered
      parsed_task = parsed(task)
      unless parsed_task[:text].strip.empty?
        all_coords += parsed_task[:coords]
        result << "*Завдання*: #{parsed_task[:text]}\n"
      end
    end
    unless help.nil?
      parsed_help = parsed(help)
      unless parsed_help[:text].strip.empty?
        all_coords += parsed_help[:coords]
        result << "*Підказка*: #{parsed(help)[:text]}\n"
      end
    end
    @coords = all_coords
    result << "\n"
    result
  end
end