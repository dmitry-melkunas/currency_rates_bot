# frozen_string_literal: true

require_relative 'response'
require_relative 'handler/access_denied'
require_relative 'handler/callback_message'
require_relative 'handler/message'
require_relative 'handler/unknown_message'

class Listener
  module Handler
    def process(bot, message_object)
      return Handler::AccessDenied.process(bot, message_object) unless enabled_user?(message_object)

      parse_message(bot, message_object)
    end

    def parse_message(bot, message_object)
      case message_object
      when Telegram::Bot::Types::Message       then Handler::Message.process(bot, message_object)
      when Telegram::Bot::Types::CallbackQuery then Handler::CallbackMessage.call(bot, message_object)
      else
        Handler::UnknownMessage.process(bot, message_object)
      end
    end

    def enabled_user?(message_object)
      user = check_or_create_user(message_object)

      user.enabled == true
    end

    def check_or_create_user(message_object)
      user = User.find_by(chat_id: message_object.chat.id)
      return user if user.present?

      User.create(
        name: message_object.from.first_name&.gsub(' ', ''),
        chat_id: message_object.chat.id,
        enabled: false,
        language: 'en'
      )
    end
  end
end
