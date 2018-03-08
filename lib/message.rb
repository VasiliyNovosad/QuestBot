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
  attr_accessor :owner_login, :id, :text, :coords

  def initialize(owner_login, id, text)
    @owner_login = owner_login
    @id = id
    @text = text
    @coords = []
  end

  def self.from_json(message_json)
    Message.new(
      message_json['OwnerLogin'],
      message_json['MessageId'],
      message_json['MessageText']
    )
  end

  def from_json(message_json)
    @owner_login = message_json['OwnerLogin']
    @text = message_json['MessageText']
  end

  def ==(other_object)
    other_object.class == self.class &&
      id == other_object.id &&
      text == other_object.text &&
      owner_login == other_object.owner_login
  end

  def to_text
    parsed_text = parsed(text)
    @coords = parsed_text[:coords]
    "*Повідомлення* від *#{parsed(owner_login)[:text]}*: #{parsed_text[:text]}\n\n"
  end
end