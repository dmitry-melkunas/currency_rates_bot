# frozen_string_literal: true

class Listener
  module Handler
    module UserInfo
      def build(message_object)
        user_info = fetch_info_from(message_object, 'from')
        chat_info = fetch_info_from(message_object, 'chat')

        {}.tap do |p|
          p['chat_id'] = fetch_param_from(user_info, 'id') || fetch_param_from(chat_info, 'id') # user ID is the same as chat ID if sending from private messages
          p['first_name'] = fetch_param_from(user_info, 'first_name') || fetch_param_from(chat_info, 'first_name')
          p['last_name'] = fetch_param_from(user_info, 'last_name') || fetch_param_from(chat_info, 'last_name')
          p['username'] = fetch_param_from(user_info, 'username')
          p['language'] = fetch_language_from(user_info)
        end.compact_blank
      rescue => e
        puts "[Listener][Handler][UserInfo] Failed to parse params from response. Error message: #{e.message}"
        CurrencyRatesBot.logger.error('[Listener][Handler][UserInfo] Failed to parse params from response. ' \
                                        "Error message: #{e.message}\n#{e.backtrace.join("\n")}")
        {}
      end

      def fetch_info_from(message_object, param)
        return nil unless (defined? message_object.public_send(param)).present?

        message_object.public_send(param)
      end

      def fetch_param_from(info, param)
        return nil unless info.present?
        return nil unless (defined? info.public_send(param)).present?

        info.public_send(param)
      end

      def fetch_language_from(user_info)
        language = fetch_param_from(user_info, 'language_code')
        return 'ru' if %w[ru rus].include?(language) # 'en' and 'ru' supported languages

        'en'
      end

      module_function(:build, :fetch_info_from, :fetch_param_from, :fetch_language_from)
    end
  end
end
