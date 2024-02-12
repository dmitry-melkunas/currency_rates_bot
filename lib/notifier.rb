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
      user_operations = user.user_operations.where(enabled: true,
                                                   currency_pair: cur_pair,
                                                   bank: bank_name,
                                                   exchange_method: ex_method)

      next unless user_operations.present?

      check_rates_and_notify(user_operations)
    end
  end

  private

  def check_rates_and_notify(user_operations)
    user_operations.each do |user_operation|
      case user_operation.define_rate_amount
      when 'buy_amount'  then notify_user(user_operation) if user_operation.rate_amount > sell_amount
      when 'sell_amount' then notify_user(user_operation) if user_operation.rate_amount < buy_amount
      end
    end
  end

  def notify_user(user_operation)
    Listener::Response.standard_message(bot,
                                        user_operation.chat_id.presence || user_operation.user.chat_id,
                                        build_message(user_operation))
  end

  def build_message(user_operation)
    update_currency_rates_for_money

    deposit_money = Money.new(user_operation.deposit_amount, user_operation.deposit_currency)
    final_money = Money.new(user_operation.final_amount, user_operation.final_currency)
    converted_money = final_money.exchange_to(user_operation.deposit_currency)
    profit_money = converted_money - deposit_money

    I18n.t('buy_sell_notification_message',
           buy_amount_and_currency: "#{converted_money} #{user_operation.deposit_currency}",
           sell_amount_and_currency: "#{final_money} #{user_operation.final_currency}",
           deposit_amount_and_currency: "#{deposit_money} #{user_operation.deposit_currency}",
           profit_amount_and_currency: "#{profit_money} #{user_operation.deposit_currency}",
           locale: user_language(user_operation))
  end

  def update_currency_rates_for_money
    first_currency, second_currency = cur_pair.split('/')

    Money.add_rate(first_currency, second_currency, buy_amount)
    Money.add_rate(second_currency, first_currency, 1 / sell_amount)
  end

  def user_language(user_operation)
    user_operation.user.language&.to_sym || :en
  end
end
