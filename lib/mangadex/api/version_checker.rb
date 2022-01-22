# typed: true
require "psych"

module Mangadex
  module Api
    class VersionChecker
      extend T::Sig

      sig { returns(T.nilable(String)) }
      def self.check_mangadex_version
        puts("Checking Mangadex's latest API version...")
        version = Psych.load(
          RestClient.get(
            'https://api.mangadex.org/api.yaml',
          ).body,
        ).dig('info', 'version')

        if version != Mangadex::Version::STRING
          warn(
            "[Warning] This gem is compatible with #{Mangadex::Version::STRING} but it looks like Mangadex is at #{version}",
            "[Warning] Check out #{Mangadex.configuration.mangadex_url} for more information.",
          )
        end

        version
      rescue => error
        nil
      end
    end
  end
end
