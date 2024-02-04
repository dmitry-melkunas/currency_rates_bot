# frozen_string_literal: true

module CurrencyRatesParams
  class Bnb
    attr_reader :urls

    def initialize(urls)
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
        rates['EUR']['USD']['BUY']  = rates.dig('EUR', 'USD', 'BUY').to_f
        rates['EUR']['USD']['SALE'] = rates.dig('EUR', 'USD', 'SALE').to_f
      end

      currency_rates
    end
  end
end
