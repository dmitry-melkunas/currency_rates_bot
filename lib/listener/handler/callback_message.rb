# frozen_string_literal: true

class Listener
  module Handler
    module CallBackMessage
      def process(bot, message_object)
        case message_object.text
        when '/start'
          Response.standard_message(bot, message_object, I18n.t('welcome', name: message_object.from.first_name))
        when '/end'
          Response.standard_message(bot, message_object, I18n.t('bye', name: message_object.from.first_name))
        else
          Response.standard_message(bot, message_object, I18n.t('unclear_message'))
        end


        # def process
        #   self.callback_message = Listener.message.message
        #   case Listener.message.data
        #   when 'get_account'
        #     Listener::Response.std_message('Нету аккаунтов на данный момент')
        #   when 'force_promo'
        #     Listener::Response.force_reply_message('Отправьте промокод')
        #   when 'advanced_menu'
        #     Listener::Response.inline_message('Дополнительное меню:', Listener::Response.generate_inline_markup([
        #                                                                                                           Inline_Button::HAVE_PROMO
        #                                                                                                         ]), true)
        #   end
        # end
      end

      module_function(:process)
    end
  end
end
