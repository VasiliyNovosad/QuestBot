class PenaltyHelp
  attr_accessor :id, :text, number, :is_penalty, :penalty, :penalty_comment, :request_confirm, :penalty_help_state, :remain_seconds, :penalty_message

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
end