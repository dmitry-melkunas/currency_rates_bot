# frozen_string_literal: true

class CurrencyRate < ActiveRecord::Base
  validates_presence_of :currency_pair, :bank, :buy_amount, :sell_amount, :exchange_method
  validates_uniqueness_of :currency_pair, :bank, :exchange_method

  validates :exchange_method, inclusion: CurrencyRatesBot::AVAILABLE_EXCHANGE_METHODS
end
