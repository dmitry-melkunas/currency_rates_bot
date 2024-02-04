# frozen_string_literal: true

class User < ActiveRecord::Base
  has_many :user_operations

  validates_presence_of :chat_id

  validates :language, inclusion: CurrencyRatesBot::AVAILABLE_LANGUAGES, length: { maximum: 2 }

  scope :enabled_users, -> { where(enabled: true) }

  def enabled?
    enabled == true
  end
end
