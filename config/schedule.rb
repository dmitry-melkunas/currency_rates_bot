# frozen_string_literal: true

set :output, './logs/cron.log'
set :chronic_options, hours24: true

# every 5.minutes do # TODO: enable
#   rake 'update_currency_rates_and_notify'
# end
