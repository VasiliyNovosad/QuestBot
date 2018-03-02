# {
#     "OwnerId": 1397283,
#     "OwnerLogin": "Жupaqp",
#     "MessageId": 24641,
#     "MessageText": "Если описание расположения локации непонятно - двигайтесь по указателям. ",
#     "WrappedText": "Если описание расположения локации непонятно - двигайтесь по указателям. ",
#     "ReplaceNl2Br": true
# }
require_relative '../lib/bot_utils'

class Message
  include BotUtils
  attr_accessor :owner_id, :owner_login, :id, :text

  def initialize(owner_id, owner_login, id, text)
    @owner_id = owner_id
    @owner_login = owner_login
    @id = id
    @text = text
  end

  def self.from_json(message_json)
    Message.new(
      message_json['OwnerId'],
      message_json['OwnerLogin'],
      message_json['MessageId'],
      message_json['MessageText']
    )
  end

  def ==(other_object)
    other_object.class == self.class &&
      id == other_object.id &&
      text == other_object.text &&
      owner_id == other_object.owner_id
  end

  def to_text
    "*Повідомлення* від *#{parsed(owner_login)}*: #{parsed(text)}\n\n"
  end
end