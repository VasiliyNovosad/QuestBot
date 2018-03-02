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
class Help
  attr_accessor :id, :text, :number, :is_penalty, :penalty, :penalty_comment, :request_confirm, :penalty_help_state, :remain_seconds, :penalty_message

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
  end

  def self.from_json(help_json)
    Help(
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
      text == other_object.text
  end

  def to_text
    result = "*Підказка #{number}*: "
    if remain_seconds.zero?
      result << "\n#{parsed(text)}\n\n"
    else
      result << "буде через *#{seconds_to_string(remain_seconds)}*\n\n"
    end
    result
  end
end