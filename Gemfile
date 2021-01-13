# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in slimer.gemspec
gemspec

gem "rake", "~> 13.0"

group :test do
  gem "minitest", "~> 5.0"
  gem "rack-test"
end

group :development, :test do
  gem "rubocop", "~> 0.80"
end
