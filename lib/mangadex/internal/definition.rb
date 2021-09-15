module Mangadex
  module Internal
    class Definition
      class << self
        def manga_list(args)
          ensure_params(
            args,
            {
              limit: Integer,
              offset: Integer,
              title: String,
              authors: Array,
              artists: Array,
              year: Integer,
              included_tags: Array,
              included_tags_mode: { value: %w(OR AND), as: -> (value) { Array(value) } },
              excluded_tags: Array,
              excluded_tags_mode: { value: %w(OR AND), as: -> (value) { Array(value) } },
              status: { value: %w(ongoing completed hiatus cancelled), as: -> (value) { Array(value) } },
              original_language: Array,
              excluded_original_language: Array,
              available_translated_language: Array,
              publication_demographic: Array,
              ids: Array,
              content_rating: { value: %w(safe suggestive erotica pornographic), as: -> (value) { Array(value) } },
              created_at_since: %r{^\d{4}-[0-1]\d-([0-2]\d|3[0-1])T([0-1]\d|2[0-3]):[0-5]\d:[0-5]\d$},
              updated_at_since: %r{^\d{4}-[0-1]\d-([0-2]\d|3[0-1])T([0-1]\d|2[0-3]):[0-5]\d:[0-5]\d$},
              order: Hash,
              includes: Array,
            },
          )
        end

        def manga_feed(args)
          ensure_params(
            args,
            {
              limit: Integer,
              offset: Integer,
              translated_language: String,
              original_language: Array,
              excluded_original_language: Array,
              content_rating: { value: %w(safe suggestive erotica pornographic), as: -> (value) { Array(value) } },
              include_future_updates: { value: %w(0 1) },
              created_at_since: %r{^\d{4}-[0-1]\d-([0-2]\d|3[0-1])T([0-1]\d|2[0-3]):[0-5]\d:[0-5]\d$},
              updated_at_since: %r{^\d{4}-[0-1]\d-([0-2]\d|3[0-1])T([0-1]\d|2[0-3]):[0-5]\d:[0-5]\d$},
              publish_at_since: %r{^\d{4}-[0-1]\d-([0-2]\d|3[0-1])T([0-1]\d|2[0-3]):[0-5]\d:[0-5]\d$},
              order: Hash,
              includes: Array,
            },
          )
        end

        def ensure_params(params, definition=nil)
          params = Hash(params).with_indifferent_access
          definition = Hash(definition).with_indifferent_access
          return params if definition.empty?

          errors = []
          params.each do |key, value|
            key = key.to_s
            if !definition.has_key?(key) && !definition.has_key?("#{key}!")
              errors << {extra: key}
            elsif definition[key]
              if definition[key].is_a?(Class) && !value.is_a?(definition[key])
                errors << {key: key, expected: definition[key], got: value.class}
              elsif definition[key].is_a?(Regexp) && !(definition[key] === value)
                errors << {key: key, expected: "matching regex #{definition[key]}", got: value}
              elsif definition[key].is_a?(Hash)
                if definition.dig(key, :value)
                  expected_value = definition.dig(key, :value).map(&:to_s) # must be an array!
                  must_be_instance_of = expected_value.first.class
                  convert_to_instance_of = definition.dig(key, :as)

                  if definition.dig(key, :required) && value.to_s.empty?
                    errors << {missing: key}
                    next
                  end
                  # binding.pry

                  if !value.is_a?(must_be_instance_of) && !convert_to_instance_of
                    errors << {key: key, expected: must_be_instance_of, got: value.class}
                    next
                  end

                  valid_value = value.is_a?(Array) ? (value - expected_value).empty? : expected_value.include?(value.to_s)

                  if valid_value
                    params[key] = convert_to_instance_of.call(value) if convert_to_instance_of
                  else
                    errors << {key: key, expected: "one of #{expected_value}", got: value}
                  end
                end
              end
            end
          end

          if errors.any?
            error_message = errors.map do |error|
              if error[:extra]
                "params[:#{error[:extra]}] does not exist and cannot be passed to this request"
              elsif error[:missing]
                "params[:#{error[:missing]}] is missing"
              else
                "params[:#{error[:key]}] to be #{error[:expected]}, got #{error[:got]}"
              end
            end.join(', ')
            raise ArgumentError, "Expected: #{error_message}"
          end

          params
        end
      end
    end
  end
end
