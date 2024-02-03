# frozen_string_literal: true

class Listener
  module Handler
    module AccessDenied
      def process(bot, user_info)
        Response.standard_message(bot,
                                  user_info['chat_id'],
                                  I18n.t('access_denied', locale: user_info['language']&.to_sym))
      end

      module_function(:process)
    end
  end
end
