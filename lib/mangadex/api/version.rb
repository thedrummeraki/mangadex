require "psych"

module Mangadex
  module Api
    VERSION = -> do
      Psych.load(
        RestClient.get(
          'https://api.mangadex.org/api.yaml',
        ).body,
      ).dig('info', 'version')
    end.call
  end
end
