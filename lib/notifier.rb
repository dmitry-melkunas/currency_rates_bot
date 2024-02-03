# frozen_string_literal: true

require 'json'

require_relative 'listener/response'

class Notifier
  attr_reader :bot, :cur_pair, :bank_name, :ex_type, :buy_amount, :sell_amount

  def initialize(bot, currency_pair, bank_name, exchange_type, buy_amount, sell_amount)
    @bot = bot
    @cur_pair = currency_pair
    @bank_name = bank_name
    @ex_type = exchange_type
    @buy_amount = buy_amount
    @sell_amount = sell_amount
  end

  def process
    user_operations_for_enabled_users = UserOperation.where(currency_pair: cur_pair,
                                                            bank: bank_name,
                                                            exchange_type: ex_type)
                                                     .joins(:user)
                                                     .where(users: { enabled: true })

    return unless user_operations_for_enabled_users.present?

    user_operations_for_enabled_users.each do |user_operation|
      check_rates_and_notify(user_operation)
    end
  end

  private

  def check_rates_and_notify(user_operation)
    case user_operation.define_rate_amount
    when 'buy_amount'  then process_with_buy_amount(user_operation)
    when 'sell_amount' then process_with_sell_amount(user_operation)
    end
  end

  def process_with_buy_amount(user_operation)
    if user_operation.rate_amount > sell_amount && user_operation.operation_type == 'buy'
      notify_to('sell', user_operation)
    elsif user_operation.rate_amount < sell_amount && user_operation.operation_type == 'sell'
      notify_to('buy', user_operation)
    end
  end

  def process_with_sell_amount(user_operation)
    if user_operation.rate_amount > buy_amount && user_operation.operation_type == 'sell'
      notify_to('buy', user_operation)
    elsif user_operation.rate_amount < buy_amount && user_operation.operation_type == 'buy'
      notify_to('sell', user_operation)
    end
  end

  def notify_to(op_type, user_operation)
    language = user_language(user_operation)

    Listener::Response.standard_message(bot,
                                        user_operation.chat_id.presence || user_operation.user.chat_id,
                                        I18n.t('buy_sell_notification_message',
                                               operation_type: I18n.t(op_type, locale: language),
                                               currency: user_operation.currency,
                                               locale: language))
  end

  def user_language(user_operation)
    user_operation.user.language&.to_sym || :en
  end
end
