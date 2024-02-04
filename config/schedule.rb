# frozen_string_literal: true

set :output, './logs/cron.log'
set :chronic_options, hours24: true

# job_type :rake_rvm, 'rvm use 3.3.0 && cd :path && bundle exec rake :task --silent :output' # enable, if using rvm

job_type :rake_rbenv, 'export PATH="$HOME/.rbenv/bin:$PATH"; eval "$(rbenv init -)"; '\
                      'cd :path && bundle exec rake :task --silent :output' # enable, if using rbenv

every 3.minutes do
  rake_rbenv 'update_currency_rates_and_notify'
end
