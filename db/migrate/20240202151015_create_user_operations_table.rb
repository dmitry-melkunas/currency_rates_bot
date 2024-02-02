# frozen_string_literal: true

class CreateUserOperationsTable < ActiveRecord::Migration[7.1]
  def up
    return if table_exists? :user_operations

    create_table :user_operations do |t|
      t.belongs_to :user
      t.bigint     :chat_id, index: true
      t.string     :currency_pair
      t.string     :bank
      t.float      :buy_amount
      t.float      :sell_amount
      t.string     :exchange_type

      t.timestamps
    end
  end

  def down
    drop_table :user_operations if table_exists? :user_operations
  end
end
