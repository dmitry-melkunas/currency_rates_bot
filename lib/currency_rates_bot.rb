# frozen_string_literal: true

require 'active_record'
require 'pg'
require 'erb'
require 'logger'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/numeric/time'
require 'money'

# for debugging
require 'pry'

module CurrencyRatesBot
  autoload :Settings, 'currency_rates_bot/settings'

  AVAILABLE_LANGUAGES = %w[en ru].freeze
  AVAILABLE_EXCHANGE_METHODS = %w[in_bank by_card online].freeze

  class << self
    def root
      File.expand_path File.join(File.dirname(__FILE__), '..')
    end

    def initialize!
      load_settings
      establish_db_connection
      define_internalization
      define_money
    end

    def establish_db_connection(config = nil)
      config ||= db_config
      ActiveRecord::Base.logger = logger
      ActiveRecord::Base.establish_connection(config)
    end

    def db_config
      YAML.load(ERB.new(File.read("#{root}/config/database.yml")).result)
    end

    def load_settings
      CurrencyRatesBot::Settings.load!
    end

    def define_internalization
      I18n.load_path += Dir["#{File.expand_path('config/locales')}/*.yml"]
      I18n.available_locales = AVAILABLE_LANGUAGES
      I18n.default_locale = :en
      I18n.backend.load_translations
    end

    def define_money
      Money.locale_backend = :i18n
      Money.rounding_mode = BigDecimal::ROUND_HALF_UP
    end

    def available_currency_pairs
      @available_currency_pairs ||= CurrencyRatesBot::Settings.currency_rates.available_currency_pairs
    end

    def enabled_banks
      @enabled_banks ||= CurrencyRatesBot::Settings.currency_rates.enabled_banks
    end

    def currency_rates_bank_urls
      @currency_rates_bank_urls ||= CurrencyRatesBot::Settings.currency_rates.urls
    end

    def telegram_bot_token
      @telegram_bot_token ||= CurrencyRatesBot::Settings.telegram.bots.default.token
    end

    def logger
      @logger ||= Logger.new("#{root}/logs/app.log",
                             'weekly',
                             datetime_format: '%Y-%m-%d %H:%M:%S',
                             progname: 'CurrencyRatesBot',
                             level: CurrencyRatesBot::Settings.debug_mode ? Logger::DEBUG : Logger::INFO)
    end
  end
end

require 'models'
require 'listener'
require 'updater'
require 'notifier'
