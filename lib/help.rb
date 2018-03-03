# {
#     "HelpId": 1521298,
#     "Number": 1,
#     "HelpText": null,
#     "IsPenalty": false,
#     "Penalty": 0,
#     "PenaltyComment": null,
#     "RequestConfirm": false,
#     "PenaltyHelpState": 0,
#     "RemainSeconds": 878,
#     "PenaltyMessage": null
# }
require_relative '../lib/bot_utils'

class Help
  include BotUtils
  attr_accessor :id, :text, :number, :is_penalty, :penalty, :penalty_comment, :request_confirm, :penalty_help_state, :remain_seconds, :penalty_message, :coords, :notified

  def initialize(id, number, text, is_penalty, penalty, penalty_comment, request_confirm, penalty_help_state, remain_seconds, penalty_message)
    @id = id
    @number = number
    @text = text
    @is_penalty = is_penalty
    @penalty = penalty
    @penalty_comment = penalty_comment
    @request_confirm = request_confirm
    @penalty_help_state = penalty_help_state
    @remain_seconds = remain_seconds
    @penalty_message = penalty_message
    @coords = []
    @notified = false
  end

  def self.from_json(help_json)
    Help.new(
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

  def from_json(help_json)
    @number = help_json['Number']
    @text = help_json['HelpText']
    @is_penalty = help_json['IsPenalty']
    @penalty = help_json['Penalty']
    @penalty_comment = help_json['PenaltyComment']
    @request_confirm = help_json['RequestConfirm']
    @penalty_help_state = help_json['PenaltyHelpState']
    @remain_seconds = help_json['RemainSeconds']
    @penalty_message = help_json['PenaltyMessage']
  end

  def ==(other_object)
    other_object.class == self.class &&
      id == other_object.id &&
      number == other_object.number &&
      text == other_object.text
  end

  def to_text
    result = "*Підказка #{number}*: "
    if remain_seconds.zero?
      parsed_text = parsed(text)
      @coords = parsed_text[:coords]
      result << "\n#{parsed_text[:text]}\n\n"
    else
      result << "буде через *#{seconds_to_string(remain_seconds)}*\n\n"
    end
    result
  end
end