# frozen_string_literal: true

require 'settingslogic'
require 'uri'

module CurrencyRatesBot
  class Settings < Settingslogic
    source "#{CurrencyRatesBot.root}/config/settings.yml"

    suppress_errors true
  end
end
