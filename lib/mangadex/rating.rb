# typed: false

module Mangadex
  class Rating < MangadexObject
    has_attributes \
      :rating,
      :created_at

    def self.list(**args)
      Mangadex::Internal::Request.get(
        '/rating',
        Mangadex::Internal::Definition.validate(args, {
          manga: { accepts: Array[String] },
        }),
        auth: true,
      )
    end
  end
end
