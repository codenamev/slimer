# frozen_string_literal: true

module Slimer
  # Defines routes and responses for the Slimer web app.
  class WebApplication
    extend WebRouter

    CONTENT_LENGTH = "Content-Length"
    REDIS_KEYS = %w[redis_version uptime_in_days connected_clients used_memory_human used_memory_peak_human].freeze
    CSP_HEADER = [
      "default-src 'self' https: http:",
      "child-src 'self'",
      "connect-src 'self' https: http: wss: ws:",
      "font-src 'self' https: http:",
      "frame-src 'self'",
      "img-src 'self' https: http: data:",
      "manifest-src 'self'",
      "media-src 'self'",
      "object-src 'none'",
      "script-src 'self' https: http: 'unsafe-inline'",
      "style-src 'self' https: http: 'unsafe-inline'",
      "worker-src 'self'",
      "base-uri 'self'"
    ].join("; ").freeze

    def initialize(klass)
      @klass = klass
    end

    def settings
      @klass.settings
    end

    def self.settings
      Slimer::Web.settings
    end

    def root_path
      "#{env["SCRIPT_NAME"]}/"
    end

    get "/" do
      json(:ok)
    end

    post "/busy" do
      if params["identity"]
        p = Sidekiq::Process.new("identity" => params["identity"])
        p.quiet! if params["quiet"]
        p.stop! if params["stop"]
      else
        processes.each do |pro|
          pro.quiet! if params["quiet"]
          pro.stop! if params["stop"]
        end
      end

      redirect "#{root_path}busy"
    end

    get "/status" do
      json(:ok)
    end

    get "/:api_key/consume" do
      forbidden unless authorized?

      Slimer::Substance.consume(params)

      json(:ok)
    end

    post "/:api_key/consume" do
      forbidden unless authorized?

      Slimer::Substance.consume(params)

      json(:ok)
    end

    get "/:api_key/:group/consume" do
      forbidden unless authorized?

      exclude_keys = ["group"]
      substance_params = params.select { |k, _v| !exclude_keys.include?(k.to_s) } # rubocop:disable Style/InverseMethods
      Slimer::Substance.consume(substance_params, group: params["group"])

      json(:ok)
    end

    post "/:api_key/:group/consume" do
      forbidden unless authorized?

      exclude_keys = ["group"]
      substance_params = params.select { |k, _v| !exclude_keys.include?(k.to_s) } # rubocop:disable Style/InverseMethods
      Slimer::Substance.consume(substance_params, group: params["group"])

      json(:ok)
    end

    def call(env)
      action = self.class.match(env)
      return [404, { "Content-Type" => "text/plain", "X-Cascade" => "pass" }, ["Not Found"]] unless action

      resp = catch(:halt) do
        action.instance_exec env, &action.block
      end

      resolve_response(resp)
    end

    def resolve_response(resp)
      return resp if resp.is_a?(Array)

      # rendered content goes here
      headers = {
        "Content-Type" => "text/html",
        "Cache-Control" => "no-cache",
        "Content-Language" => "en",
        "Content-Security-Policy" => CSP_HEADER
      }
      # we'll let Rack calculate Content-Length for us.
      [200, headers, [resp]]
    end

    def self.helpers(mod = nil, &block)
      if block
        WebAction.class_eval(&block)
      else
        WebAction.send(:include, mod)
      end
    end
  end
end
