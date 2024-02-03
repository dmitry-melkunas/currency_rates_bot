# frozen_string_literal: true

class Listener
  module Handler
    module Message
      def process(bot, user_info, message_object)
        case message_object.text
        when '/start'
          Response.standard_message(bot,
                                    user_info['chat_id'],
                                    I18n.t('welcome',
                                           name: user_info['first_name'].presence || user_info['username'],
                                           locale: user_info['language']))
        when '/end'
          Response.standard_message(bot,
                                    user_info['chat_id'],
                                    I18n.t('bye',
                                           name: user_info['first_name'].presence || user_info['username'],
                                           locale: user_info['language']))
        else
          Response.standard_message(bot,
                                    user_info['chat_id'],
                                    I18n.t('unclear_message', locale: user_info['language']))
        end
      end

      module_function(:process)
    end
  end
end
