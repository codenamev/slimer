# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in slimer.gemspec
gemspec

gem "rake"

group :development do
  gem "gem-release"
end

group :test do
  gem "minitest"
  gem "rack-test"
end

group :development, :test do
  gem "rainbow", ">= 3.1.0"
  gem "rubocop"
  gem "rubocop-minitest"
  gem "rubocop-performance", require: false
  gem "rubocop-rake"
  # TODO: Figure out why the GitHub action needs this.
  gem "rubocop-rspec"
end
