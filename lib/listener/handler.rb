# frozen_string_literal: true

require_relative 'response'
require_relative 'handler/access_denied'
require_relative 'handler/callback_message'
require_relative 'handler/message'
require_relative 'handler/unknown_message'
require_relative 'handler/user_info'

class Listener
  module Handler
    def process(bot, message_object)
      user_info = Handler::UserInfo.build(message_object)
      return Handler::AccessDenied.process(bot, user_info['chat_id']) unless passed_authorization?(user_info)

      parse_message(bot, user_info, message_object)
    end

    def passed_authorization?(user_info)
      enabled_user?(user_info)
    end

    def enabled_user?(user_info)
      handle_user(user_info).enabled?
    end

    def handle_user(user_info)
      user = User.find_by(chat_id: user_info['chat_id'])
      return update_user_info(user, user_info) if user.present?

      User.create(user_params_for_db(user_info).compact_blank)
    end

    def update_user_info(user, user_info)
      user_params = user_params_for_db(user_info)
      return user if prepare_user_attributes(user.attributes) == user_params.stringify_keys

      user.update(user_params.except(:chat_id).compact_blank)
      user
    end

    def prepare_user_attributes(user_attributes)
      user_attributes.except('id', 'enabled', 'created_at', 'updated_at') # do not remember change here, if add or remove columns in users table
    end

    def user_params_for_db(user_info)
      {
        first_name: user_info['first_name'],
        last_name: user_info['last_name'],
        username: user_info['username'],
        chat_id: user_info['chat_id'],
        language: user_info['language']
      }
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
