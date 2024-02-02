# frozen_string_literal: true

class CreateCurrencyRatesTable < ActiveRecord::Migration[7.1]
  def up
    return if table_exists? :currency_rates

    create_table :currency_rates do |t|
      t.string :currency_pair
      t.string :bank
      t.float  :buy_amount
      t.float  :sell_amount
      t.string :exchange_type

      t.timestamps
    end

    add_index :currency_rates, %i[currency_pair bank exchange_type], unique: true
  end

  def down
    drop_table :currency_rates if table_exists? :currency_rates
  end
end
