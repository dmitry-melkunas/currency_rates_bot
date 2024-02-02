# frozen_string_literal: true

require 'active_record'

class User < ActiveRecord::Base
  has_many :user_operation

  validates_presence_of :chat_id
  validates_length_of :language, maximum: 2

  def enabled?
    enabled == true
  end

  # TODO: add some validations, methods
end
