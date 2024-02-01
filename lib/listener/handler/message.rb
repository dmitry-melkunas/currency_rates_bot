# frozen_string_literal: true

class Listener
  module Handler
    module Message
      def process(bot, message_object)
        case message_object.text
        when '/start'
          Response.standard_message(bot, message_object, I18n.t('welcome', name: message_object.from.first_name))
        when '/end'
          Response.standard_message(bot, message_object, I18n.t('bye', name: message_object.from.first_name))
        else
          Response.standard_message(bot, message_object, I18n.t('unclear_message'))
        end
      end

      module_function(:process)
    end
  end
end
