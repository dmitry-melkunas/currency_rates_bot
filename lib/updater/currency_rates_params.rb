# frozen_string_literal: true

require_relative 'currency_rates_params/bnb'

class Updater
  module CurrencyRatesParams
    def build_params(bank_urls)
      bank_params = prepare_params(bank_urls)

      currency_rates_params = {}
      bank_params.each do |bank_name, urls|
        currency_rates_params[bank_name] = "CurrencyRatesParams::#{bank_name.classify}".constantize.new(urls).process
      end

      currency_rates_params
    end

    def prepare_params(params)
      bank_urls = params.dup

      bank_urls.each_value(&:compact_blank!).compact_blank!
    end
  end
end
