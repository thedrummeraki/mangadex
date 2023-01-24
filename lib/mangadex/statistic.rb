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
        :thread_id,
        :replies_count

      def self.attributes_to_inspect
        [:replies_count]
      end
    end

    attr_accessor \
      :rating,
      :follows,
      :comments

    class << self
      def from_data(data)
        results = if data.is_a?(Array)
          data.map do |item|
            from_data(item)
          end
        else
          data.keys.map do |manga_id|
            statistics = data[manga_id]
            new(
              rating: Mangadex::Statistic::Rating.from_data(statistics['rating'], direct: true),
              comments: Mangadex::Statistic::Comments.from_data(statistics['comments'], direct: true),
              follows: statistics['follows'],
            )
          end
        end

        return results.first if results.length == 1
        Mangadex::Api::Response::Collection.new(results)
      end
    end

    sig { params(uuid: String, raw: T::Boolean).returns(T::Api::GenericResponse) }
    def self.get(uuid, raw: false)
      Mangadex::Internal::Definition.must(uuid)

      Mangadex::Internal::Request.get(
        '/statistics/manga/%{uuid}' % {uuid: uuid},
        raw: raw,
      )
    end

    sig { params(raw: T::Boolean, args: T::Api::Arguments).returns(T::Api::GenericResponse) }
    def self.list(raw: false, **args)
      Mangadex::Internal::Request.get(
        '/statistics/manga',
        Mangadex::Internal::Definition.validate(args, {
          manga: { accepts: [String], converts: :to_a },
        }),
        raw: raw,
      )
    end

    def self.attributes_to_inspect
      [:follows, :rating, :comments]
    end
  end
end
