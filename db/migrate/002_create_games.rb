class CreateGames < ActiveRecord::Migration[5.1]
  def change
    create_table :games, force: true do |t|
      t.integer :uid
      t.string :domain
      t.bigint :chat_id
      t.string :chat_type
    end
  end
end