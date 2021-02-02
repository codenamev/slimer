# Slimer

![build status](https://github.com/codenamev/slimer/workflows/Tests/badge.svg)

A minimalist consumer with an endless appetite.

<figcaption>
  <img src="https://github.com/codenamev/slimer/raw/main/examples/slimer-banner.jpg" alt="Slimer" />
  <small>Slimer character created by <a href="https://dribbble.com/amungioli">Anthony Mungioli</a></small>
</figcaption>

## Pre-Build Deployment Options

- [Run Within Docker](https://github.com/codenamev/slimer-example-docker)
- [![Deploy to Heroku](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/codenamev/slimer-example-heroku)

## WTF

Working with IoT, I constantly find a need for a single place to dump generic data that I want to keep track of. If this were a physical place, there would be different bins I could throw this data into. Basically what I was looking for was an organized dumpster. Enter: `Slimer`!

Slimer exists with a sole purpose: consuming _substances_. Currently, these
_substances_ are molded in a data object with the following attributes:

| attribute | description                                                                               |
| --------- | -----------                                                                               |
| uid       | A unique identifier (UUID by default)                                                     |
| payload   | `JSON` representation of the data to be stored                                            |
| metadata  | `JSON` representation of any meta-data that describes the contents of the above `payload` |
| group     | The name for a collection of similar Substance(s)                                         |

With the Slimer app running on `http://localhost:6660` (local and Docker default), and an API key generated (`rake slimer:api_keys:generate["your-name"]`) you can give it any arbitrary JSON data you want to
store either via GET:

```
http://localhost:6660/:api_key/consume?zipCode=19101&weather=sunny
```

Or via POST

```bash
curl --header "Content-Type: application/json" \
  --request POST \
  --data '{"zipCode":"19101","weather":{"cloudCover":0,description:"sunny"}}' \
  http://localhost:6660/:api_key/consume
```

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

Slimer uses Sidekiq to line up it's meals. While it is recommended to deploy Slimer (locally via Docker or on Heroku), `Slimer::Web` is a simple mountable Rack app. All that is needed is a `config.ru` file:

```ruby
# ./config.ru

require "slimer/web"

run Slimer::Web
```

## Configuration

By default, Slimer uses SQLite for storing it's Substances, and the WEBrick web server.

Slimer uses the [sequel gem](http://sequel.jeremyevans.net/) to interact with
the database. You can use whatever database it supports. Slimer will look for the
`DATABASE_URL` environment variable and use it if one exists. Alternatively, you
can configure the server explicitly:

```ruby
# ./config.ru

require "pg"
require "slimer/web"

Slimer.configure do |config|
  config.database_url = "postgres://slimer-database/?pool=8"
end

run Slimer::Web
```

Slimer accepts many configurable options:

```ruby
# By default, Slimer stores everything in the "general" group.
# Adding more groups here will make them available for consumption at:
#   /:api_key/:group/consume
Slimer.configure do |config|
  # Top-level group
  config.group :bookmarks
  # Nested group
  config.group "bookmarks/ruby"
  # Alternative nested group
  config.group :bookmarks do
    config.group :ruby
    config.group :rails
  end

  config.database_url = "postgres://slimer-database/?pool=8"
  config.sidekiq_queue = "slimed"
  config.configure_sidekiq_client do |sidekiq_config|
    sidekiq_config.redis = { url: 'redis://redis.example.com:7372/0' }
  end
  config.configure_sidekiq_server do |sidekiq_config|
    sidekiq_config.redis = { url: 'redis://redis.example.com:7372/0' }
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/codenamev/slimer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/codenamev/slimer/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Slimer project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/codenamev/slimer/blob/main/CODE_OF_CONDUCT.md).
