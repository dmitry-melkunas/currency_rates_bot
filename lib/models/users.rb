# frozen_string_literal: true

require 'active_record'

class User < ActiveRecord::Base
  has_many :user_operation
  has_many :user_operations_history

  validates_presence_of :chat_id

  validates :language, inclusion: CurrencyRatesBot::AVAILABLE_LANGUAGES, length: { maximum: 2 }

  def enabled?
    enabled == true
  end
end
