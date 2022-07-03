# typed: false

module Mangadex
  module Internal
    module Definitions
      class ContentRating < Base
        def initialize(value)
          super(
            value,
            key: :content_rating,
            accepts: Accepts.new(
              array: Mangadex::ContentRating::VALUES,
              class: Mangadex::ContentRating,
              condition: :or,
            ),
            converts: :to_s
          )
        end

        def validate_accepts
          @accepts.validate!(converted_value)
        rescue ArgumentError => error
          add_error(error.message)
        end

        def validate_condition

        end
      end
    end
  end
end
