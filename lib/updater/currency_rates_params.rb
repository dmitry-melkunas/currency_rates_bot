# frozen_string_literal: true

require_relative 'currency_rates_params/bnb'

class Updater
  module CurrencyRatesParams
    def build_params
      currency_rates_params = {}
      prepare_bank_params.each do |bank_name, urls|
        currency_rates_params[bank_name] = "CurrencyRatesParams::#{bank_name.classify}".constantize
                                                                                       .new(available_currency_pairs, urls)
                                                                                       .process
      end

      currency_rates_params
    end

    def prepare_bank_params
      params = bank_urls.dup

      params.delete_if { |bank_name, _urls| enabled_banks.exclude?(bank_name) }
            .each_value(&:compact_blank!)
            .compact_blank!
    end
  end
end
