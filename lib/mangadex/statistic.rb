# typed: false

module Mangadex
  class Statistic < MangadexObject
    has_attributes \
      :rating,
      :average,
      :bayesian,
      :distribution,
      :follows

    sig { params(uuid: String).returns(T::Api::GenericResponse) }
    def self.get(uuid)
      Mangadex::Internal::Definition.must(uuid)

      Mangadex::Internal::Request.get(
        '/statistics/manga/%{uuid}' % {uuid: uuid},
      )
    end
  end
end
