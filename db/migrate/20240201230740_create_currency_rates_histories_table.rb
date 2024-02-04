# frozen_string_literal: true

class CreateCurrencyRatesHistoriesTable < ActiveRecord::Migration[7.1]
  def up
    return if table_exists? :currency_rates_histories

    create_table :currency_rates_histories do |t|
      t.string :currency_pair, index: true
      t.string :bank, index: true
      t.float  :buy_amount
      t.float  :sell_amount
      t.string :exchange_method, index: true

      t.timestamps
    end
  end

  def down
    drop_table :currency_rates_histories if table_exists? :currency_rates_histories
  end
end
