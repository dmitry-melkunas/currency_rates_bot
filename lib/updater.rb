# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'nokogiri'
require 'json'
require 'money'

class Updater
  attr_reader :urls

  def self.run
    new.process
  end

  def initialize
    @urls = CurrencyRatesBot.currency_rates_urls
  end

  def process
    currency_rates = fetch_currency_rates
    prepare_amounts_in(currency_rates)
    update_eur_usd_amounts_from(currency_rates)
  rescue => e
    CurrencyRatesBot.logger.error("[Updater] Failed update. Error message: #{e.message}\n"\
                                  "#{e.backtrace.join("\n")}")
  end

  private

  def fetch_currency_rates
    uri = URI(urls['bnb'])
    response = Net::HTTP.get(uri)
    html_parsed_content = Nokogiri::HTML(response)
    currency_rates = html_parsed_content.xpath('/html/body/div[1]/div[2]/div[2]/div[2]/div/div[1]/div[3]/input[2]')
                                        .last
                                        .attributes
                                        .values
                                        .last
                                        .value
    JSON.parse(currency_rates)
  end

  def prepare_amounts_in(currency_rates)
    buy_amount  = Money.from_amount(currency_rates.dig('EUR', 'USD', 'BUY'), 'USD').cents.to_s # TODO: change logic of preparing
    sell_amount = Money.from_amount(currency_rates.dig('EUR', 'USD', 'SALE'), 'USD').cents.to_s # TODO: change logic of preparing

    currency_rates['EUR']['USD']['BUY'] = buy_amount
    currency_rates['EUR']['USD']['SALE'] = sell_amount
  end

  def update_eur_usd_amounts_from(currency_rates)
    params = {
      currency_pair: 'EUR/USD',
      buy_amount: currency_rates.dig('EUR', 'USD', 'BUY'),
      sell_amount: currency_rates.dig('EUR', 'USD', 'SALE'),
      bank: 'bnb',
      exchange_type: 'online'
    }

    currency_rate = CurrencyRate.find_by(currency_pair: 'EUR/USD', bank: 'bnb', exchange_type: 'online')
    if currency_rate.present?
      currency_rate.update(buy_amount: params[:buy_amount], sell_amount: params[:sell_amount])
    else
      CurrencyRate.create(params)
    end

    CurrencyRatesHistory.create(params)
  end
end
