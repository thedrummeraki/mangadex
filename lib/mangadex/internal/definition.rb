# typed: true

require_relative "definitions/accepts"

require_relative "definitions/base"
require_relative "definitions/content_rating"

module Mangadex
  module Internal
    class Definition
      attr_reader :key, :value, :converts, :accepts, :required
      attr_reader :errors

      def initialize(key, value, converts: nil, accepts: nil, required: false)
        @converts = converts
        @key = key
        @value = convert_value(value)
        @raw_value = value
        @accepts = accepts
        @required = required ? true : false
        @errors = Array.new
      end

      def empty?
        value.respond_to?(:empty?) ? value.empty? : value.to_s.strip.empty?
      end

      def validate!
        validate_required!
        validate_accepts!

        true
      end

      def valid?
        validate!
      rescue ArgumentError
        false
      end

      def error
        validate! && nil
      rescue ArgumentError => error
        error.message
      end

      def convert_value(value)
        if converts.is_a?(Proc)
          converts.call(value)
        elsif converts.is_a?(String) || converts.is_a?(Symbol)
          value.send(converts)
        else
          value
        end
      end

      def validate_required!
        return unless required

        if empty?
          raise ArgumentError, "Missing :#{key}"
        end
      end

      def validate_accepts!
        return if value.nil? && !required
        return unless accepts

        if accepts.is_a?(Class) && !value.is_a?(accepts)
          raise ArgumentError, "Expected :#{key} to be a #{accepts}, but got a #{value.class}"
        end
        if accepts.is_a?(Regexp) && !(accepts === value)
          raise ArgumentError, "Expected :#{key} to match /#{accepts}/"
        end
        if accepts.is_a?(Array)
          if accepts.count == 1 && accepts[0].is_a?(Class)
            expected_class = accepts[0]
            if !value.is_a?(Array)
              raise ArgumentError, "Expected :#{key} to be an Array of #{expected_class}, but got #{value}"
            end

            invalid_elements = []
            value.each do |x|
              invalid_elements << x unless x.is_a?(expected_class)
            end
            return if invalid_elements.empty?
            bad = invalid_elements.map { |x| "<#{x}:#{x.class}>" }
            raise ArgumentError, "Expected elements in :#{key} to be an Array of #{expected_class}, but found #{bad}"
          else
            if value.is_a?(Array)
              extra_elements = value - accepts
              return if extra_elements.empty?
              raise ArgumentError, "Expected elements in :#{key} to be one of #{accepts}, but found #{extra_elements}"
            elsif !(value.nil? || (value.respond_to?(:empty?) && value.empty?)) && !accepts.include?(value)
              raise ArgumentError, "Expected :#{key} to be one of #{accepts}, but got #{@raw_value}:#{@raw_value.class}"
            end
          end
        end
      end

      class << self
        def converts(key=nil)
          procs = { to_a: -> ( x ) { Array(x) } }
          return procs if key.nil?

          procs[key]
        end

        def chapter_list(args)
          validate(
            args,
            {
              limit: { accepts: Integer },
              offset: { accepts: Integer },
              ids: { accepts: [String] },
              title: { accepts: String },
              manga: { accepts: String },
              groups: { accepts: [String] },
              uploader: { accepts: [String], converts: converts(:to_a) },
              chapter: { accepts: [String], converts: converts(:to_a) },
              translated_language: { accepts: [String], converts: converts(:to_a) },
              original_language: { accepts: [String] },
              excluded_original_language: { accepts: [String] },
              content_rating: Definitions::ContentRating,
              include_future_updates: { accepts: %w(0 1) },
              created_at_since: { accepts: %r{^\d{4}-[0-1]\d-([0-2]\d|3[0-1])T([0-1]\d|2[0-3]):[0-5]\d:[0-5]\d$} },
              updated_at_since: { accepts: %r{^\d{4}-[0-1]\d-([0-2]\d|3[0-1])T([0-1]\d|2[0-3]):[0-5]\d:[0-5]\d$} },
              publish_at_since: { accepts: %r{^\d{4}-[0-1]\d-([0-2]\d|3[0-1])T([0-1]\d|2[0-3]):[0-5]\d:[0-5]\d$} },
              order: { accepts: Hash },
              includes: { accepts: [String], converts: converts(:to_a) },
            },
          )
        end

        def must(*args)
          args = args.each_with_index.map do |arg, index|
            ["arg_at_position_#{index}".to_sym, arg]
          end.to_h

          definition = args.keys.map do |key|
            [key, { required: true }]
          end.to_h

          validate(args, definition)
          args.values
        end

        def validate(args, definition)
          args = Hash(args)
          definition = Hash(definition)
          return args if definition.empty?

          errors = []
          extra_keys = args.keys - definition.keys
          extra_keys.each do |extra_key|
            errors << { extra: extra_key }
          end

          definition.each do |key, definition|
            validation_error = if definition.is_a?(Class) && definition < Definitions::Base
              validator = definition.new(args[key])
              validator.validate
              validator.error_message
            elsif !definition.is_a?(Class)
              validator = Definition.new(key, args[key], **definition.symbolize_keys)
              validator.error
            else
              raise "Invalid definition class: #{definition}"
            end

            if validation_error
              errors << { message: validation_error }
            elsif !validator.empty?
              args[key] = validator.value
            end
          end

          if errors.any?
            error_message = errors.map do |error|
              if error[:extra]
                "params[:#{error[:extra]}] does not exist and cannot be passed to this request"
              elsif error[:message]
                error[:message]
              else
                error.to_s
              end
            end.join(', ')
            raise ArgumentError, "Validation error: #{error_message}"
          end

          args.symbolize_keys
        end
      end
    end
  end
end
