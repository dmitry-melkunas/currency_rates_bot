# frozen_string_literal: true

require 'active_record'
require 'erb'
require 'logger'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/object/to_query'
require 'active_support/core_ext/object/with_options'
require 'active_support/core_ext/numeric/time'
require 'active_support/security_utils'

# for debugging
require 'pry'

module CurrencyRatesBot
  autoload :Settings, 'currency_rates_bot/settings'

  class << self
    def root
      File.expand_path File.join(File.dirname(__FILE__), '..')
    end

    def initialize!
      establish_db_connection
      load_settings
      define_internalization
    end

    def establish_db_connection(config = nil)
      config ||= db_config
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
      I18n.default_locale = :en
      I18n.backend.load_translations
    end

    def currency_rates_bank_urls
      @currency_rates_urls ||= CurrencyRatesBot::Settings.currency_rates.urls
    end

    def telegram_bot_token
      @telegram_bot_token ||= CurrencyRatesBot::Settings.telegram.bots.default.token
    end

    def error_notifier_telegram_bot_token
      @error_notifier_telegram_bot_token ||= CurrencyRatesBot::Settings.telegram.bots.error_notifier.token
    end

    def logger
      @logger ||= Logger.new("#{root}/tmp/logs.log",
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
