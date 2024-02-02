# frozen_string_literal: true

class Listener
  module Response
    def standard_message(bot, id, message)
      bot.api.send_message(chat_id: id, text: message)
    end

    module_function(:standard_message)
  end
end
