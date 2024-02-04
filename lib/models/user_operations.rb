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
    currency_pair_array = currency_pair.split('/')

    if currency_pair_array.index(deposit_currency).zero? && currency_pair_array.index(final_currency) == 1
      'buy_amount'
    elsif currency_pair_array.index(final_currency).zero? && currency_pair_array.index(deposit_currency) == 1
      'sell_amount'
    end
  end
end
