# frozen_string_literal: true

class CreateUserOperationsTable < ActiveRecord::Migration[7.1]
  def up
    return if table_exists? :user_operations

    create_table :user_operations do |t|
      t.belongs_to :user
      t.bigint     :chat_id
      t.string     :currency_pair, index: true
      t.string     :bank, index: true
      t.string     :exchange_method, index: true
      t.float      :rate_amount
      t.integer    :deposit_amount
      t.string     :deposit_currency, limit: 3
      t.integer    :final_amount
      t.string     :final_currency, limit: 3

      t.timestamps
    end
  end

  def down
    drop_table :user_operations if table_exists? :user_operations
  end
end
