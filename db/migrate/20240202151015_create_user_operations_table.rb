# frozen_string_literal: true

class CreateUserOperationsTable < ActiveRecord::Migration[7.1]
  def up
    return if table_exists? :user_operations

    create_table :user_operations do |t|
      t.belongs_to :user
      t.bigint     :chat_id
      t.string     :operation_type, limit: 4
      t.string     :currency_pair
      t.string     :bank
      t.string     :exchange_type
      t.string     :currency, limit: 3
      t.float      :rate_amount
      t.integer    :deposit_amount
      t.integer    :converted_amount

      t.timestamps
    end

    add_index :user_operations, %i[chat_id operation_type currency_pair bank exchange_type currency], unique: true
  end

  def down
    drop_table :user_operations if table_exists? :user_operations
  end
end
