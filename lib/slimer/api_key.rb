# frozen_string_literal: true

require "securerandom"

module Slimer
  # A Sequel::Model wrapper around the api_keys table
  class ApiKey < Sequel::Model
    def self.generate(name)
      new_token = loop do
        generated_token = SecureRandom.urlsafe_base64
        break generated_token unless token_exists?(generated_token)
      end

      create name: name, token: new_token
    end

    def self.token_exists?(token)
      ApiKey.where(token: token).count.positive?
    end
  end
end
