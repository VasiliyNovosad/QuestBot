class Message
  attr_accessor :owner_id, :owner_login, :id, :text

  def initialize(owner_id, owner_login, id, text)
    @owner_id = owner_id
    @owner_login = owner_login
    @id = id
    @text = text
  end
end