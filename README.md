# Slimer

![build status](https://github.com/codenamev/slimer/workflows/Tests/badge.svg)

A minimalist consumer with an endless appetite.

<figcaption>
  <img src="https://github.com/codenamev/slimer/raw/main/examples/slimer-banner.jpg" alt="Slimer" />
  <small>Created by <a href="https://dribbble.com/amungioli">Anthony Mungioli</a></small>
</figcaption>

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'slimer'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install slimer

## Usage

Slimer uses Sidekiq to line up it's meals.

```ruby
# By default, Slimer stores everything in the "general" group.
# Adding more groups here will make them available for consumption at:
#   /:api_key/:group/consume
Slimer.configure do |config|
  # Top-level group
  group :bookmarks
  # Nested group
  group "bookmarks/ruby"
  # Alternative nested group
  group :bookmarks do
    group :ruby
    group :rails
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/codenamev/slimer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/codenamev/slimer/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Slimer project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/codenamev/slimer/blob/master/CODE_OF_CONDUCT.md).
