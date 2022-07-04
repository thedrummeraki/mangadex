# typed: false

module Mangadex
  module Internal
    module Definitions
      class Base
        attr_reader :key, :accepts, :converts, :errors

        def initialize(value, key:, accepts:, required: false, converts: nil)
          @value = value
          @key = key
          @accepts = accepts
          @required = required
          @converts = converts
          @errors = Array.new
        end

        def validate
          validate_required
          return if !@required && empty?

          validate_accepts

          nil
        end

        def validate!
          validate

          raise_if_any_errors!
        end

        def valid?
          validate!
          true
        rescue ArgumentError
          false
        end

        def error_message
          return unless errors.any?

          compile_error_message
        end

        def empty?
          converted_value.respond_to?(:empty?) ? converted_value.empty? : converted_value.to_s.strip.empty?
        end

        def value
          converted_value
        end

        protected

        def validate_required
          return unless @required

          add_error("Missing :#{key}") if empty?
          false
        end

        def validate_accepts
          raise NotImplementedError
        end

        def converted_value
          @converted_value ||= if converts.is_a?(Proc)
            converts.call(@value)
          elsif converts.is_a?(String) || converts.is_a?(Symbol)
            @value.send(converts)
          else
            @value
          end
        end

        def add_error(message)
          @errors << message
          @errors.uniq!
        end

        def compile_error_message
          errors.join(', ')
        end

        private

        def raise_if_any_errors!
          raise ArgumentError, "Validation error: #{compile_error_message}" if errors.any?
        end
      end
    end
  end
end
