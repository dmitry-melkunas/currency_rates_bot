# frozen_string_literal: true

require 'active_record'

class UserOperation < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :chat_id, :currency_pair, :bank, :buy_amount, :sell_amount, :exchange_type

  def user_by_chat_id
    User.find_by(chat_id: chat_id)
  end

  # TODO: add some validations, methods
end
