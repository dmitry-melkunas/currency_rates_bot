# frozen_string_literal: true

require_relative 'listener/response'

class Notifier
  attr_reader :bot, :cur_pair, :bank_name, :ex_method, :buy_amount, :sell_amount

  def initialize(bot, currency_pair, bank_name, exchange_method, buy_amount, sell_amount)
    @bot = bot
    @cur_pair = currency_pair
    @bank_name = bank_name
    @ex_method = exchange_method
    @buy_amount = buy_amount
    @sell_amount = sell_amount
  end

  def process
    enabled_users = User.enabled_users
    return unless enabled_users.present?

    enabled_users.each do |user|
      last_user_operation = user.user_operations.where(currency_pair: cur_pair,
                                                       bank: bank_name,
                                                       exchange_method: ex_method).last

      next unless last_user_operation.present?

      check_rates_and_notify(last_user_operation)
    end
  end

  private

  def check_rates_and_notify(user_operation)
    case user_operation.define_rate_amount
    when 'buy_amount'  then notify_user(user_operation) if user_operation.rate_amount > sell_amount
    when 'sell_amount' then notify_user(user_operation) if user_operation.rate_amount < buy_amount
    end
  end

  def notify_user(user_operation)
    language = user_language(user_operation)

    Listener::Response.standard_message(bot,
                                        user_operation.chat_id.presence || user_operation.user.chat_id,
                                        I18n.t('buy_sell_notification_message',
                                               buy_currency: user_operation.deposit_currency,
                                               sell_currency: user_operation.final_currency,
                                               locale: language))
  end

  def user_language(user_operation)
    user_operation.user.language&.to_sym || :en
  end
end
