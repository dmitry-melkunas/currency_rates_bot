# frozen_string_literal: true

class CreateUserOperationsHistoriesTable < ActiveRecord::Migration[7.1]
  def up
    return if table_exists? :user_operations_histories

    create_table :user_operations_histories do |t|
      t.belongs_to :user
      t.bigint     :chat_id, index: true
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
  end

  def down
    drop_table :user_operations_histories if table_exists? :user_operations_histories
  end
end
