# frozen_string_literal: true

require 'active_record'

class UserOperationsHistory < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :user_id, :chat_id, :type, :currency_pair, :bank, :exchange_type, :currency, :rate_amount,
                        :deposit_amount, :converted_amount

  validates :type, inclusion: CurrencyRatesBot::AVAILABLE_OPERATION_TYPES, length: { maximum: 4 }
  validates :exchange_type, inclusion: CurrencyRatesBot::AVAILABLE_EXCHANGE_TYPES
  validates :currency, length: { maximum: 3 }

  def user_by_chat_id
    User.find_by(chat_id: chat_id)
  end
end
