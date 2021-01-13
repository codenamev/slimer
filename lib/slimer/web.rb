# frozen_string_literal: true

require "slimer"
require "slimer/web/helpers"

require "slimer/web/router"
require "slimer/web/action"
require "slimer/web/application"
require "slimer/web/csfr_protection"

require "rack/builder"
require "rack/content_length"
require "rack/session/cookie"

# Slimer
module Slimer
  # The Slimer web application on Rack
  # Borrowed from Slidekiq:
  # https://github.com/mperham/sidekiq/blob/master/lib/sidekiq/web.rb
  class Web
    class << self
      def settings
        self
      end

      def middlewares
        @middlewares ||= []
      end

      def enable(*opts)
        opts.each { |key| set(key, true) }
      end

      def disable(*opts)
        opts.each { |key| set(key, false) }
      end

      # Helper for the Sinatra syntax: Slimer::Web.set(:session_secret, Rails.application.secrets...)
      def set(attribute, value)
        send(:"#{attribute}=", value)
      end

      attr_accessor :app_url, :session_secret, :sessions
    end

    # rubocop:disable Lint/MissingSuper
    def self.inherited(child)
      child.app_url = app_url
      child.session_secret = session_secret
      child.redis_pool = redis_pool
      child.sessions = sessions
    end
    # rubocop:enable Lint/MissingSuper

    def settings
      self.class.settings
    end

    def use(*middleware_args, &block)
      middlewares << [middleware_args, block]
    end

    def middlewares
      @middlewares ||= Web.middlewares.dup
    end

    def call(env)
      app.call(env)
    end

    def self.call(env)
      @app ||= new
      @app.call(env)
    end

    def app
      @app ||= build
    end

    def enable(*opts)
      opts.each { |key| set(key, true) }
    end

    def disable(*opts)
      opts.each { |key| set(key, false) }
    end

    def set(attribute, value)
      send(:"#{attribute}=", value)
    end

    # Default values
    set :sessions, true

    attr_writer :sessions

    def sessions
      unless instance_variable_defined?("@sessions")
        @sessions = self.class.sessions
        @sessions = @sessions.to_hash.dup if @sessions.respond_to?(:to_hash)
      end

      @sessions
    end

    def self.register(extension)
      extension.registered(WebApplication)
    end

    private

    def using?(middleware)
      middlewares.any? do |(m, _)|
        m.is_a?(Array) && (m[0] == middleware || m[0].is_a?(middleware))
      end
    end

    def build_sessions
      middlewares = self.middlewares

      s = sessions

      # turn on CSRF protection if sessions are enabled and this is not the test env
      middlewares.unshift [[CsrfProtection], nil] if s && !using?(CsrfProtection) && ENV["RACK_ENV"] != "test"

      configure_cookie_middleware if s && !using?(::Rack::Session::Cookie)
      middlewares.unshift [[::Rack::ContentLength], nil] unless using? ::Rack::ContentLength
    end

    def configure_cookie_middleware
      unless (secret = Web.session_secret)
        require "securerandom"
        secret = SecureRandom.hex(64)
      end

      options = { secret: secret }
      options = options.merge(sessions.to_hash) if sessions.respond_to? :to_hash

      middlewares.unshift [[::Rack::Session::Cookie, options], nil]
    end

    def build
      build_sessions

      middlewares = self.middlewares
      klass = self.class

      ::Rack::Builder.new do
        middlewares.each { |middleware, block| use(*middleware, &block) }

        run WebApplication.new(klass)
      end
    end
  end

  Slimer::WebApplication.helpers WebHelpers
end
