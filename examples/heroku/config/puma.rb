# frozen_string_literal: true

workers ENV.fetch("WEB_CONCURRENCY", 2)
threads_count = ENV.fetch("RAILS_MAX_THREADS", 5)
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV.fetch("PORT", 3000)
environment ENV.fetch("RAILS_ENV", "development")

on_worker_boot do
  # Similar to the worker specific setup for Rails 4.1+,
  # We want to establish a DB connection here
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  Slimer.db
end

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart
