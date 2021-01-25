# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in slimer.gemspec
gemspec

gem "rake", "~> 13.0"

group :development do
  gem "gem-release"
end

group :test do
  gem "minitest", "~> 5.0"
  gem "rack-test"
end

group :development, :test do
  gem "rainbow", ">= 3.1.0", github: "sickill/rainbow"
  gem "rubocop", "~> 0.81" # This version supports Ruby 2.3
  gem "rubocop-minitest"
  gem "rubocop-performance", require: false
  gem "rubocop-rake"
  # TODO: Figure out why the GitHub action needs this.
  gem "rubocop-rspec"
end
