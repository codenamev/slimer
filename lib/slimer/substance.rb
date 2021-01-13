# frozen_string_literal: true

module Slimer
  # A data object Slimer consumes
  class Substance < Sequel::Model
    plugin :serialization, :json, :payload

    def self.consume(payload, options = {})
      description = options.delete(:description)
      group = options.delete(:group) || Slimer::DEFAULT_GROUP

      Slimer::Workers::IngestSubstance.perform_async(
        payload,
        group,
        description
      )
    end
  end
end
