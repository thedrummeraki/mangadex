# typed: false

module Mangadex
  module Internal
    module Definitions
      class Year < Base
        def initialize(value)
          super(
            value,
            key: :year,
            accepts: Accepts.new(
              array: ["none"],
              class: Integer,
              condition: :or,
            ),
            required: false,
          )
        end

        def validate_accepts
          @accepts.validate!(converted_value)
        rescue ArgumentError => error
          add_error(error.message)
        end
      end
    end
  end
end
