# frozen_string_literal: true

module Slimer
  # Everything needed for handling an HTTP request
  # Borrowed from Sidekiq:
  #   https://github.com/mperham/sidekiq/blob/master/lib/sidekiq/web/action.rb
  class WebAction
    RACK_SESSION = "rack.session"

    attr_accessor :env, :block, :type

    def settings
      Web.settings
    end

    def request
      @request ||= ::Rack::Request.new(env)
    end

    def halt(res)
      throw :halt, res
    end

    def redirect(location)
      throw :halt, [302, { "Location" => "#{request.base_url}#{location}" }, []]
    end

    def forbidden
      throw :halt, [403, { "Content-Type" => "text/plain" }, ["Forbidden"]]
    end

    def authorized?
      api_key = route_params.delete(:api_key)
      return false unless api_key

      Slimer::ApiKey.where(token: api_key).count.positive?
    end

    def params
      indifferent_hash = Hash.new { |hash, key| hash[key.to_s] if Symbol === key } # rubocop:disable Style/CaseEquality

      indifferent_hash.merge! request.params
      route_params.each { |k, v| indifferent_hash[k.to_s] = v }

      indifferent_hash
    end

    def route_params
      env[WebRouter::ROUTE_PARAMS]
    end

    def session
      env[RACK_SESSION]
    end

    def json(payload)
      [200, { "Content-Type" => "application/json", "Cache-Control" => "no-cache" }, [JSON.generate(payload)]]
    end

    def initialize(env, block)
      @env = env
      @block = block
      @files ||= {}
    end
  end
end
