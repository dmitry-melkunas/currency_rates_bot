# frozen_string_literal: true

require 'active_record'

class CurrencyRate < ActiveRecord::Base
  validates_presence_of :currency_pair, :bank, :buy_amount, :sell_amount, :exchange_type

  validates :exchange_type, inclusion: CurrencyRatesBot::AVAILABLE_EXCHANGE_TYPES
end
