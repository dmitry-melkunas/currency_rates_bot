# frozen_string_literal: true

set :output, './logs/cron.log'
set :chronic_options, hours24: true

# job_type :rake_rvm, 'rvm use 3.3.0 && cd :path && bundle exec rake :task --silent :output' # enable, if using rvm

job_type :rake_rbenv, 'export PATH="$HOME/.rbenv/bin:$PATH"; eval "$(rbenv init -)"; '\
                      'cd :path && bundle exec rake :task --silent :output' # enable, if using rbenv

times = []
(6..23).each do |hour|
  (0..57).step(3) do |minute|
    prepare_minute = minute.to_s.length == 1 ? "0#{minute}" : minute
    times.push("#{hour}:#{prepare_minute}")
  end
end

every :weekday, at: times do # from 6:00 to 23:57 every 3 minutes in work days
  rake_rbenv 'update_currency_rates_and_notify'
end
