# frozen_string_literal: true

class Listener
  module Response
    def standard_message(bot, message_object, message)
      bot.api.send_message(chat_id: message_object.chat.id, text: message)
    end

    module_function(
      :standard_message
    )
  end
end
