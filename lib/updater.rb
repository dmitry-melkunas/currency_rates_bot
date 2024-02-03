# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'nokogiri'
require 'json'
# require 'money' # TODO: enable if needed

require_relative 'updater/currency_rates_params'

class Updater
  DEFAULT_CURRENCY_PAIR = 'EUR/USD'
  BUY = 'BUY'
  SELL = 'SALE'

  include CurrencyRatesParams

  attr_reader :bank_urls

  def self.run
    new.process
  end

  def initialize
    @bank_urls = CurrencyRatesBot.currency_rates_bank_urls
  end

  def process
    currency_rates = build_params(bank_urls)
    update_and_notify_from(currency_rates)
    CurrencyRatesBot.logger.info('[Updater] Currency rates successfully updated and notified')
  rescue => e
    puts "[Updater] Failed update. Error message: #{e.message}"
    CurrencyRatesBot.logger.error("[Updater] Failed update. Error message: #{e.message}\n"\
                                  "#{e.backtrace.join("\n")}")
  end

  private

  def update_and_notify_from(currency_rates)
    currency_rates.each do |bank_name, exchange_type_params|
      exchange_type_params.each do |exchange_type, rates|
        buy_amount = fetch_amount_from(rates, BUY)
        sell_amount = fetch_amount_from(rates, SELL)

        update_currency_rate(bank_name, exchange_type, buy_amount, sell_amount)
        process_currency_rate_for_history(bank_name, exchange_type, buy_amount, sell_amount)

        notify_users(bank_name, exchange_type, buy_amount, sell_amount)
      end
    end
  end

  def fetch_amount_from(rates, type)
    rates.dig(DEFAULT_CURRENCY_PAIR.split('/').first, DEFAULT_CURRENCY_PAIR.split('/').last, type)
  end

  def update_currency_rate(bank_name, ex_type, buy_am, sell_am)
    currency_rate = CurrencyRate.find_by(currency_pair: DEFAULT_CURRENCY_PAIR,
                                         bank: bank_name,
                                         exchange_type: ex_type)

    if currency_rate.present?
      currency_rate.update(buy_amount: buy_am, sell_amount: sell_am)
    else
      CurrencyRate.create(currency_rates_params_for_db(bank_name, buy_am, sell_am, ex_type))
    end
  end

  def process_currency_rate_for_history(bank_name, ex_type, buy_am, sell_am)
    currency_rate_history = CurrencyRatesHistory.where(currency_pair: DEFAULT_CURRENCY_PAIR,
                                                       bank: bank_name,
                                                       exchange_type: ex_type)&.last

    return create_currency_rate_for_history(bank_name, ex_type, buy_am, sell_am) unless currency_rate_history.present?
    return if equal_amounts?(currency_rate_history, buy_am, sell_am)

    create_currency_rate_for_history(bank_name, ex_type, buy_am, sell_am)
  end

  def create_currency_rate_for_history(bank_name, ex_type, buy_am, sell_am)
    CurrencyRatesHistory.create(currency_rates_params_for_db(bank_name, buy_am, sell_am, ex_type))
  end

  def equal_amounts?(currency_rate_history, buy_am, sell_am)
    currency_rate_history.buy_amount == buy_am&.to_f &&
      currency_rate_history.sell_amount == sell_am&.to_f
  end

  def currency_rates_params_for_db(bank_name, buy_am, sell_am, ex_type)
    {
      currency_pair: DEFAULT_CURRENCY_PAIR,
      bank: bank_name,
      buy_amount: buy_am,
      sell_amount: sell_am,
      exchange_type: ex_type
    }.compact_blank
  end

  def notify_users(bank_name, exchange_type, buy_amount, sell_amount)
    Notifier.new(bot,
                 DEFAULT_CURRENCY_PAIR,
                 bank_name,
                 exchange_type,
                 buy_amount,
                 sell_amount).process
  end

  def bot
    @bot ||= Telegram::Bot::Client.new(CurrencyRatesBot.telegram_bot_token,
                                       logger: CurrencyRatesBot.logger)
  end
end
