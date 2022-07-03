# typed: false

module Mangadex
  module Internal
    module Definitions
      class Accepts
        VALID_CONDITIONS = [:and, :or]

        class Possibility
          def initialize(accepted:)
            @accepted = accepted
          end

          def inspect
            "{#{@accepted.class.name}: #{@accepted}}"
          end
        end

        def initialize(array: nil, class: nil, value: nil, condition: :and)
          @array = array
          @class = binding.local_variable_get(:class)
          @value = value
          @condition = ensure_valid_condition!(condition.to_s.to_sym)
        end

        def validate!(value)
          valid = if @condition == :or
            validate_or!(value)
          else
            validate_and!(value)
          end

          raise ArgumentError, "Value `#{value}` must be #{nature}: #{possibilities}" unless valid
        end

        private

        def ensure_valid_condition!(condition)
          return condition if VALID_CONDITIONS.include?(condition)

          raise "Condition `#{condition}` must be one of #{VALID_CONDITIONS}"
        end

        def nature
          @condition == :or ? "one of" : "all of"
        end

        def validate_and!(value)
          possibilities.all? { potentially_valid?(value) }
        end

        def validate_or!(value)
          possibilities.any? { potentially_valid?(value) }
        end

        def possibilities
          @possibilities ||= [
            @array,
            @class,
            @value,
          ].compact.map { |pos| Possibility.new(accepted: pos) }
        end

        def potentially_valid?(value)
          @array.include?(value) || \
            value.is_a?(@class) || \
            value == @value
        end
      end
    end
  end
end
