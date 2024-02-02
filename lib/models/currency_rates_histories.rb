# frozen_string_literal: true

require 'active_record'

class CurrencyRatesHistory < ActiveRecord::Base
  validates_presence_of :currency_pair, :bank, :buy_amount, :sell_amount, :exchange_type

  # TODO: add some validations, methods
end
