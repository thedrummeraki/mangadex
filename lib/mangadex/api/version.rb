# typed: true
require "psych"

module Mangadex
  module Api
    VERSION = -> do
      version = Psych.load(
        RestClient.get(
          'https://api.mangadex.org/api.yaml',
        ).body,
      ).dig('info', 'version')

      if version != Mangadex::VERSION
        warn(
          "[Warning] This gem is compatible with #{Mangadex::VERSION} but it looks like Mangadex is at #{version}",
          "[Warning] Check out #{Mangadex::Internal::Request::BASE_URI} for more information.",
        )
      end

      version
    end.call
  end
end
