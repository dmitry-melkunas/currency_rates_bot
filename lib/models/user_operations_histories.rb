# frozen_string_literal: true

class UserOperationsHistory < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :user_id, :chat_id, :operation_type, :currency_pair, :bank, :exchange_type, :currency,
                        :rate_amount, :deposit_amount, :converted_amount

  validates :operation_type, inclusion: CurrencyRatesBot::AVAILABLE_OPERATION_TYPES, length: { maximum: 4 }
  validates :exchange_type, inclusion: CurrencyRatesBot::AVAILABLE_EXCHANGE_TYPES
  validates :currency, length: { maximum: 3 }

  def user_by_chat_id
    User.find_by(chat_id: chat_id)
  end

  def define_rate_amount
    currency_pair_array = currency_pair.split('/')

    case operation_type
    when 'buy'  then currency_pair_array.index(currency).zero? ? 'sell_amount' : 'buy_amount'
    when 'sell' then currency_pair_array.index(currency).zero? ? 'buy_amount' : 'sell_amount'
    end
  end
end
