source "https://rubygems.org"

ruby "3.3.0"
gem "rails", "~> 8.0.2"

gem "pg"
gem "puma"
gem "bootsnap", require: false

gem "stripe"
gem "enumerize"
gem "aasm"
gem "sidekiq"

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false

  gem "rspec-rails", "~> 7.1.0"
  gem "factory_bot_rails"
end
