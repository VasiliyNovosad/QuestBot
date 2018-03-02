# {
#     "HelpId": 1534612,
#     "Number": 1,
#     "HelpText": null,
#     "IsPenalty": true,
#     "Penalty": 1800,
#     "PenaltyComment": "Взяв штрафную подсказку Вам будет начислено 30мин штрафа и ПЛЮС ВРЕМЯ ДО АВТОПЕРЕХОДА. Код, полученный по штрафной подсказке, необходимо внести в поле \"ответ\" - уровень закроется.",
#     "RequestConfirm": true,
#     "PenaltyHelpState": 0,
#     "RemainSeconds": 0,
#     "PenaltyMessage": null
# }
require_relative '../lib/bot_utils'

class PenaltyHelp
  include BotUtils
  attr_accessor :id, :number, :text, :is_penalty, :penalty, :comment, :request_confirm,
                :help_state, :remain_seconds, :message

  def initialize(id, number, text, is_penalty, penalty, comment, request_confirm, help_state, remain_seconds, message)
    @id = id
    @number = number
    @text = text
    @is_penalty = is_penalty
    @penalty = penalty
    @comment = comment
    @request_confirm = request_confirm
    @help_state = help_state
    @remain_seconds = remain_seconds
    @message = message
  end

  def self.from_json(help_json)
    PenaltyHelp.new(
        help_json['HelpId'],
        help_json['Number'],
        help_json['HelpText'],
        help_json['IsPenalty'],
        help_json['Penalty'],
        help_json['PenaltyComment'],
        help_json['RequestConfirm'],
        help_json['PenaltyHelpState'],
        help_json['RemainSeconds'],
        help_json['PenaltyMessage']
    )
  end

  def ==(other_object)
    other_object.class == self.class &&
      id == other_object.id &&
      number == other_object.number &&
      text == other_object.text &&
      penalty == other_object.penalty &&
      comment == other_object.comment &&
      message == other_object.message &&
      help_state == other_object.help_state
  end

  def to_text
    result = "*Штрафна підказка #{number}*: "
    if remain_seconds.zero?
      result << "\n*Опис*: #{parsed(comment)}" unless comment.nil? || comment == ''
      result << "\n*Підказка*: #{parsed(text)}" unless text.nil? || text == ''
      result << "\n*Штраф*: #{seconds_to_string(penalty)}\n\n"
    else
      result << "буде через *#{seconds_to_string(remain_seconds)}*\n\n"
    end
    result
  end
end