# frozen_string_literal: true

class Listener
  module Handler
    module AccessDenied
      def process(bot, id)
        Response.standard_message(bot, id, I18n.t('access_denied'))
      end

      module_function(:process)
    end
  end
end
