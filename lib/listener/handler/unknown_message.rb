# frozen_string_literal: true

class Listener
  module Handler
    module UnknownMessage
      def process(bot, message_object)
        Response.standard_message(bot, message_object, I18n.t('unknown_message_type'))
      end

      module_function(:process)
    end
  end
end
