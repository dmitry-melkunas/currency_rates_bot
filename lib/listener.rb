# frozen_string_literal: true

require 'telegram/bot'
require_relative 'listener/handler'

class Listener
  include Handler

  attr_reader :token, :token_for_errors

  def self.run
    new.listener
  end

  def initialize
    @token            = CurrencyRatesBot.telegram_bot_token
    @token_for_errors = CurrencyRatesBot.error_notifier_telegram_bot_token
  end

  def listener
    bot
    define_stop_signal_for_bot
    bot.listen { |message_object| process(bot, message_object) }
  rescue => e
    puts "[Listener] Immediately stop bot. Error message: #{e.message}"
    CurrencyRatesBot.logger.error('[Listener] Immediately stop bot. '\
                                  "Error message: #{e.message}\n#{e.backtrace.join("\n")}")
  end

  private

  def bot
    @bot ||= Telegram::Bot::Client.new(CurrencyRatesBot.telegram_bot_token)
  end

  def define_stop_signal_for_bot
    Signal.trap('INT') do
      bot.stop
      puts("\n\n[Listener] Stop bot by signal")
    end
  end
end
