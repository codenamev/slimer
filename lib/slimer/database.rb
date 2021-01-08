# frozen_string_literal: true

require "sequel/core"

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
      new(url).connection
    end

    def connection
      @connection ||= Sequel.connect(url)
    end

    def resolve_missing_tables!
      return if migrated?

      create!
    end

    def create!
      connection.create_table(:substances) do
        primary_key :id
        String :uid
        String :group
        Array :tags
        String :description
        String :payload, text: true
        String :payload_type
        full_text_index :payload if connection.supports_text_index?
      end unless connection.table_exists?(:substances)

      connection.create_table(:api_keys) do
        primary_key :id
        String :name
        String :token
      end unless connection.table_exists?(:api_keys)
    end

    def migrated?
      REQUIRED_TABLES.all? { |t| connection.table_exists?(t) }
    end
  end
end
