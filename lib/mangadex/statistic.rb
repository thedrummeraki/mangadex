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

    sig { params(args: T::Api::Arguments).returns(T::Api::GenericResponse) }
    def self.list(**args)
      to_a = Mangadex::Internal::Definition.converts(:to_a)

      Mangadex::Internal::Request.get(
        '/statistics/manga',
        Mangadex::Internal::Definition.validate(args, {
          manga: { accepts: [String], converts: to_a },
        })
      )
    end
  end
end
