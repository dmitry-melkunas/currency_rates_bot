# frozen_string_literal: true

class Listener
  module Handler
    module Message
      def process(bot, user_info, message_object)
        case message_object.text
        when '/start'
          Response.standard_message(bot, user_info['chat_id'], I18n.t('welcome', name: user_info['first_name'].presence || user_info['username']))
        when '/end'
          Response.standard_message(bot, user_info['chat_id'], I18n.t('bye', name: user_info['first_name'].presence || user_info['username']))
        else
          Response.standard_message(bot, user_info['chat_id'], I18n.t('unclear_message'))
        end
      end

      module_function(:process)
    end
  end
end
