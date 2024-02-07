# frozen_string_literal: true

module CurrencyRatesParams
  class Bnb
    attr_reader :available_currency_pairs, :urls

    def initialize(available_currency_pairs, urls)
      @available_currency_pairs = available_currency_pairs
      @urls = urls
    end

    def process
      currency_rates = fetch_currency_rates
      prepare_amounts_in(currency_rates)
    end

    private

    def fetch_currency_rates
      {}.tap do |p|
        p['in_bank'] = fetch_in_bank_currency_rates if urls['in_bank'].present?
        p['by_card'] = fetch_by_card_currency_rates if urls['by_card'].present?
        p['online'] = fetch_by_online_currency_rates if urls['online'].present?
      end
    end

    def fetch_in_bank_currency_rates
      nil # add if needed
    end

    def fetch_by_card_currency_rates
      nil # add if needed
    end

    def fetch_by_online_currency_rates
      # example of params: { 'EUR' => { 'USD' => { 'BUY' => 1.09, 'SALE' => 1.10 } } }

      uri = URI(urls['online'])
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
      currency_rates.each_value do |rates|
        available_currency_pairs.each do |currency_pair|
          first_currency, second_currency = currency_pair.split('/')

          rates[first_currency][second_currency]['BUY']  = rates.dig(first_currency, second_currency, 'BUY').to_f
          rates[first_currency][second_currency]['SALE'] = rates.dig(first_currency, second_currency, 'SALE').to_f
        end
      end

      currency_rates
    end
  end
end
