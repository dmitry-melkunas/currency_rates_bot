# frozen_string_literal: true

require_relative 'response'
require_relative 'handler/authorization'
require_relative 'handler/access_denied'
require_relative 'handler/callback_message'
require_relative 'handler/message'
require_relative 'handler/unknown_message'
require_relative 'handler/user_info'

class Listener
  module Handler
    def process(bot, message_object)
      user_info = Handler::UserInfo.build(message_object)
      return Handler::AccessDenied.process(bot, user_info) unless Handler::Authorization.passed_authorization?(user_info)

      parse_message(bot, user_info, message_object)
    end

    def parse_message(bot, user_info, message_object)
      case message_object
      when Telegram::Bot::Types::Message       then Handler::Message.process(bot, user_info, message_object)
      when Telegram::Bot::Types::CallbackQuery then Handler::CallbackMessage.process(bot, user_info, message_object)
      else
        Handler::UnknownMessage.process(bot, user_info)
      end
    end
  end
end
