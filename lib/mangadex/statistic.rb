# typed: false

module Mangadex
  class Statistic < MangadexObject
    class Rating < MangadexObject
      has_attributes \
        :average,
        :bayesian,
        :distribution

      def self.attributes_to_inspect
        [:average, :bayesian]
      end
    end

    class Comments < MangadexObject
      has_attributes \
        :threadId,
        :repliesCount

      def self.attributes_to_inspect
        [:id, :threadId, :repliesCount]
      end
    end

    attr_accessor \
      :rating,
      :follows,
      :comments

    class << self
      def from_data(data)
        statistics = data[data.keys.first]
        new(
          rating: Mangadex::Statistic::Rating.from_data(statistics['rating'], direct: true),
          comments: Mangadex::Statistic::Comments.from_data(statistics['comments'], direct: true),
          follows: statistics['follows'],
        )
      end
    end

    sig { params(uuid: String).returns(T::Api::GenericResponse) }
    def self.get(uuid)
      Mangadex::Internal::Definition.must(uuid)

      Mangadex::Internal::Request.get(
        '/statistics/manga/%{uuid}' % {uuid: uuid},
      )
    end

    sig { params(args: T::Api::Arguments).returns(T::Api::GenericResponse) }
    def self.list(**args)
      Mangadex::Internal::Request.get(
        '/statistics/manga',
        Mangadex::Internal::Definition.validate(args, {
          manga: { accepts: [String], converts: :to_a },
        })
      )
    end

    def self.attributes_to_inspect
      [:follows, :rating, :comments]
    end
  end
end
