# frozen_string_literal: true

class UserOperation < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :user_id, :chat_id, :currency_pair, :bank, :exchange_method, :rate_amount, :deposit_amount,
                        :deposit_currency, :final_amount, :final_currency

  validates :exchange_method, inclusion: CurrencyRatesBot::AVAILABLE_EXCHANGE_METHODS
  validates_length_of :deposit_currency, :final_currency, maximum: 3

  def user_by_chat_id
    User.find_by(chat_id: chat_id)
  end

  def define_rate_amount
    first_currency, second_currency = currency_pair.split('/')

    if first_currency == deposit_currency && second_currency == final_currency
      'buy_amount'
    elsif first_currency == final_currency && second_currency == deposit_currency
      'sell_amount'
    end
  end
end
