# frozen_string_literal: true

class CreateUsersTable < ActiveRecord::Migration[7.1]
  def up
    return if table_exists? :users

    create_table :users do |t|
      t.string  :first_name
      t.string  :last_name
      t.string  :username
      t.bigint  :chat_id, index: { unique: true }
      t.boolean :enabled, default: false
      t.string  :language, limit: 2

      t.timestamps
    end
  end

  def down
    drop_table :users if table_exists? :users
  end
end
