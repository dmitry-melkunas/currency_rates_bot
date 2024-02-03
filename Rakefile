# frozen_string_literal: true

$:.unshift File.expand_path('lib', File.dirname(__FILE__))

require 'rubygems'
require 'bundler/setup'

require './lib/currency_rates_bot'

CurrencyRatesBot.initialize!

namespace :db do
  namespace :generate do
    desc 'Create new migration'
    task :migration, [:name] do |_t, args|
      timestamp = Time.new.strftime('%Y%m%d%H%M%S')
      content = [
        '# frozen_string_literal: true',
        '',
        "class #{args[:name].classify} < ActiveRecord::Migration[7.1]",
        '  def up',
        '  end',
        '',
        '  def down',
        '  end',
        'end',
        ''
      ].join("\n")
      File.write("db/migrate/#{timestamp}_#{args[:name]}.rb", content)

      puts "\n#{args[:name].classify} migration was successfully created!"
    end
  end

  desc 'Check database exists'
  task :exists? do
    CurrencyRatesBot.establish_db_connection
    ActiveRecord::Base.connection.exec_query('SELECT 1').rows.first == [1]
  end

  desc 'Migrate the database'
  task :migrate do
    CurrencyRatesBot.establish_db_connection
    ActiveRecord::MigrationContext.new(ActiveRecord::Migrator.migrations_paths.first).migrate
  end

  desc 'Roll back the migration (use steps with STEP=n)'
  task :rollback do
    step = ENV['STEP'] ? ENV['STEP'].to_i : 1
    CurrencyRatesBot.establish_db_connection
    ActiveRecord::MigrationContext.new(ActiveRecord::Migrator.migrations_paths.first).rollback(step)
  end
end

desc 'Update currency rates and notify'
task :update_currency_rates_and_notify do
  CurrencyRatesBot.logger.info('[Rake] Starting update currency rates and notify')
  Updater.run
end
