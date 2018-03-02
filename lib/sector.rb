# {
#     "SectorId": 1941603,
#     "Order": 1,
#     "Name": "Учительская",
#     "Answer": {
#         "Answer": "Ирис",
#         "AnswerDateTime": {
#             "Value": 63642995776770
#         },
#         "Login": "Mishytka",
#         "UserId": 69789,
#         "LocDateTime": null
#     },
#     "IsAnswered": true
# }
#
require_relative '../lib/bot_utils'

class Sector
  include BotUtils
  attr_accessor :id, :order, :name, :answer, :is_answered

  def initialize(id, order, name, is_answered, answer)
    @id = id
    @order = order
    @name = name
    @answer = answer
    @is_answered = is_answered
  end

  def self.from_json(sector_json)
    Sector.new(
        sector_json['SectorId'],
        sector_json['Order'],
        sector_json['Name'],
        sector_json['IsAnswered'],
        sector_json['IsAnswered'] ? sector_json['Answer']['Answer'] : nil
    )
  end

  def ==(other_object)
    other_object.class == self.class &&
      id == other_object.id &&
      name == other_object.name &&
      answer == other_object.answer &&
      is_answered == other_object.is_answered
  end

  def to_text
    is_answered ? "Сектор *#{parsed(name)}* закрито кодом *#{parsed(answer)}*\n" : "Сектор *#{parsed(name)}*"
  end
end