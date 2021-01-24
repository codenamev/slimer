# frozen_string_literal: true

require "json"
require "sequel/core"
require "sequel/model"
require "sequel/plugins/serialization"

module Slimer
  # @abstract Wraps Sequel.connect to easily interface with the Slimer database
  class Database
    attr_reader :url

    MAX_CONNECTION_RETRIES = 10
    REQUIRED_TABLES = %i[api_keys substances].freeze

    def initialize(url)
      @url = url
      add_supported_extensions
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
      retry_count = 1
      @connection ||= Sequel.connect(url)
    rescue Sequel::DatabaseConnectionError
      Slimer.logger.warn "Waiting for database to become available... #{retry_count}"
      sleep 1 and retry if retry_count >= MAX_CONNECTION_RETRIES
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

    def add_supported_extensions
      return if connection.database_type != :postgres

      connection.extension :pg_json
      Sequel.extension :pg_json_ops
    end

    def create_substances
      return create_substances_for_postgres if connection.database_type == :postgres

      connection.create_table(:substances, ignore_index_errors: true) do
        primary_key :id
        String :uid
        String :group, default: Slimer::DEFAULT_GROUP
        String :payload, text: true
        String :metadata, text: true
        full_text_index :payload
        full_text_index :metadata
      end
    end

    def create_substances_for_postgres
      connection.create_table(:substances, ignore_index_errors: true) do
        String :uid
        String :group, default: Slimer::DEFAULT_GROUP
        JSONB :payload
        JSONB :metadata
        index :payload, type: :gin
        index :metadata, type: :gin
      end
    end

    def create_api_keys
      connection.create_table(:api_keys, ignore_index_errors: true) do
        primary_key :id
        String :name
        String :token
      end
    end
  end
end
