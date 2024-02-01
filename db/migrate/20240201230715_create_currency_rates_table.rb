# frozen_string_literal: true

class CreateCurrencyRatesTable < ActiveRecord::Migration[7.1]
  def up
    return if table_exists? :currency_rates

    create_table :currency_rates do |t|
      t.string  :currency_pair
      t.integer :buy_amount
      t.integer :sell_amount
      t.string  :bank
      t.string  :exchange_type

      t.timestamps
    end
  end

  def down
    drop_table :currency_rates if table_exists? :currency_rates
  end
end
