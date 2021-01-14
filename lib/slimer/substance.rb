# frozen_string_literal: true

module Slimer
  # A data object Slimer consumes
  class Substance < Sequel::Model
    plugin :serialization
    serialize_attributes :json, :payload
    serialize_attributes :json, :metadata

    def self.consume(payload, options = {})
      metadata = options.delete(:metadata)
      group = options.delete(:group) || Slimer::DEFAULT_GROUP

      Slimer::Workers::IngestSubstance.perform_async(
        payload,
        group,
        metadata
      )
    end
  end
end
