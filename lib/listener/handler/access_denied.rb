# frozen_string_literal: true

class Listener
  module Handler
    module AccessDenied
      def process(bot, message_object)
        Response.standard_message(bot, message_object, I18n.t('access_denied'))
      end

      module_function(:process)
    end
  end
end
