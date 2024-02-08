# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'nokogiri'
require 'json'

require_relative 'updater/currency_rates_params'

class Updater
  BUY = 'BUY'
  SELL = 'SALE'

  include CurrencyRatesParams

  attr_reader :available_currency_pairs, :enabled_banks, :bank_urls

  def self.run
    new.process
  end

  def initialize
    @available_currency_pairs = CurrencyRatesBot.available_currency_pairs
    @enabled_banks = CurrencyRatesBot.enabled_banks
    @bank_urls = CurrencyRatesBot.currency_rates_bank_urls
  end

  def process
    currency_rates = build_params
    update_and_notify_from(currency_rates)
    CurrencyRatesBot.logger.info('[Updater] Currency rates successfully updated and notified')
  rescue => e
    puts "[Updater] Failed update. Error message: #{e.message}"
    CurrencyRatesBot.logger.error("[Updater] Failed update. Error message: #{e.message}\n"\
                                  "#{e.backtrace.join("\n")}")
  end

  private

  def update_and_notify_from(currency_rates)
    currency_rates.each do |bank_name, exchange_method_params|
      exchange_method_params.each do |exchange_method, rates|
        available_currency_pairs.each do |currency_pair|
          buy_amount, sell_amount = fetch_amounts_from(rates, currency_pair)
          next if buy_amount.blank? || sell_amount.blank?

          update_currency_rate(currency_pair, bank_name, exchange_method, buy_amount, sell_amount)
          process_currency_rate_for_history(currency_pair, bank_name, exchange_method, buy_amount, sell_amount)

          notify_users(currency_pair, bank_name, exchange_method, buy_amount, sell_amount)
        end
      end
    end
  end

  def fetch_amounts_from(rates, currency_pair)
    first_currency, second_currency = currency_pair.split('/')

    [rates.dig(first_currency, second_currency, BUY), rates.dig(first_currency, second_currency, SELL)]
  end

  def update_currency_rate(cur_pair, bank_name, ex_method, buy_am, sell_am)
    currency_rate = CurrencyRate.find_by(currency_pair: cur_pair,
                                         bank: bank_name,
                                         exchange_method: ex_method)

    if currency_rate.present?
      currency_rate.update(buy_amount: buy_am, sell_amount: sell_am)
    else
      CurrencyRate.create(currency_rates_params_for_db(cur_pair, bank_name, buy_am, sell_am, ex_method))
    end
  end

  def process_currency_rate_for_history(cur_pair, bank_name, ex_method, buy_am, sell_am)
    currency_rate_history = CurrencyRatesHistory.where(currency_pair: cur_pair,
                                                       bank: bank_name,
                                                       exchange_method: ex_method)&.last

    return create_currency_rate_for_history(cur_pair, bank_name, ex_method, buy_am, sell_am) unless currency_rate_history.present?
    return if equal_amounts?(currency_rate_history, buy_am, sell_am)

    create_currency_rate_for_history(cur_pair, bank_name, ex_method, buy_am, sell_am)
  end

  def create_currency_rate_for_history(cur_pair, bank_name, ex_method, buy_am, sell_am)
    CurrencyRatesHistory.create(currency_rates_params_for_db(cur_pair, bank_name, buy_am, sell_am, ex_method))
  end

  def equal_amounts?(currency_rate_history, buy_am, sell_am)
    currency_rate_history.buy_amount == buy_am&.to_f &&
      currency_rate_history.sell_amount == sell_am&.to_f
  end

  def currency_rates_params_for_db(cur_pair, bank_name, buy_am, sell_am, ex_method)
    {
      currency_pair: cur_pair,
      bank: bank_name,
      buy_amount: buy_am,
      sell_amount: sell_am,
      exchange_method: ex_method
    }.compact_blank
  end

  def notify_users(cur_pair, bank_name, exchange_method, buy_amount, sell_amount)
    Notifier.new(bot,
                 cur_pair,
                 bank_name,
                 exchange_method,
                 buy_amount,
                 sell_amount).process
  end

  def bot
    @bot ||= Telegram::Bot::Client.new(CurrencyRatesBot.telegram_bot_token,
                                       logger: CurrencyRatesBot.logger)
  end
end
