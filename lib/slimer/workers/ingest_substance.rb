# frozen_string_literal: true

require "securerandom"

module Slimer
  module Workers
    # The Sidekiq::Worker responsible for ingesting Substance(s)
    class IngestSubstance
      include Sidekiq::Worker
      sidekiq_options queue: Slimer.options[:sidekiq_queue]

      def perform(payload, group = Slimer::DEFAULT_GROUP, metadta = nil)
        Slimer::Substance.create(
          payload: payload,
          group: group,
          metadata: metadta,
          uid: SecureRandom.uuid
        )
      end
    end
  end
end
