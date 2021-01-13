# frozen_string_literal: true

require "json"
require "sequel/core"
require "sequel/model"
require "sequel/plugins/serialization"

module Slimer
  # @abstract Wraps Sequel.connect to easily interface with the Slimer database
  class Database
    attr_reader :url

    REQUIRED_TABLES = %i[api_keys substances].freeze

    def initialize(url)
      @url = url
      resolve_missing_tables!
      connection.loggers << Slimer.logger if connection.loggers.empty?
    end

    def self.connection(url)
      db = new(url)
      # Sequel::Model requires a connection before you can subclass.  Now that
      # we have a connection, require the models.
      connection = db.connection
      db.load_models
      connection
    end

    def connection
      @connection ||= Sequel.connect(url)
    end
    alias connect connection

    def resolve_missing_tables!
      return if migrated?

      create!
    end

    def create!
      create_substances unless connection.table_exists?(:substances)
      create_api_keys unless connection.table_exists?(:api_keys)
    end

    def migrated?
      REQUIRED_TABLES.all? { |t| connection.table_exists?(t) }
    end

    def load_models
      require_relative "api_key" unless defined?(Slimer::ApiKey)
      require_relative "substance" unless defined?(Slimer::Substance)
    end

    private

    def create_substances
      connection.create_table(:substances, ignore_index_errors: true) do
        primary_key :id
        String :uid
        String :group, default: Slimer::DEFAULT_GROUP
        String :description
        String :payload, text: true
        String :payload_type, default: "json"
        full_text_index :payload
      end
    end

    def create_api_keys
      connection.create_table(:api_keys) do
        primary_key :id
        String :name
        String :token
      end
    end
  end
end
