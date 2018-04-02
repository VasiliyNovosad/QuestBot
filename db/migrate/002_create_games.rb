class CreateGames < ActiveRecord::Migration[5.1]
  def change
    create_table :games, force: true do |t|
      t.integer :uid
      t.string :domain
      t.bigint :chat_id
      t.string :chat_type
      t.integer :notify_before, default: 5
      t.integer :timer_interval, default: 5
      t.boolean :start_timer, default: false
      t.boolean :block_sector_update, default: false
      t.boolean :blocked_answer, default: true
      t.boolean :block_answer, default: false
    end
  end
end