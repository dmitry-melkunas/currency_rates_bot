# frozen_string_literal: true

class Listener
  module Handler
    module UnknownMessage
      def process(bot, user_info)
        Response.standard_message(bot, user_info['chat_id'], I18n.t('unknown_message_type'))
      end

      module_function(:process)
    end
  end
end
