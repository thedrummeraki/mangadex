module Mangadex
  module Api
    class Response < Mangadex::MangadexObject
      attr_accessor :result, :response, :errors, :data
      attr_accessor :limit, :offset, :total

      def self.attributes_to_inspect
        %i(result errors limit offset total data)
      end

      class Error < Mangadex::MangadexObject
        attr_accessor :id, :status, :title, :detail

        def self.attributes_to_inspect
          %i(id status title detail)
        end
      end

      class Collection < Array
        def to_s
          result_text = count == 0 || count > 1 ? "results" : "result"
          "[...#{count} #{result_text}]"
        end
      end

      class << self
        def coerce(data)
          if data['errors']
            coerce_errors(data)
          elsif data['response'] == 'entity'
            coerce_entity(data)
          elsif data['response'] == 'collection'
            coerce_collection(data)
          else
            data
          end
        end

        private

        def coerce_errors(data)
          new(
            result: data['result'],
            response: data['response'],
            errors: (
              data['errors'].map do |error_data|
                Error.new(
                  id: error_data['id'],
                  status: error_data['status'],
                  title: error_data['title'],
                  detail: error_data['detail'],
                )
              end
            ),
          )
        end

        def coerce_entity(data)
          object_type = data['type'] || data.dig('data', 'type')

          # Derive the class name from the type. "Convention over configuration"
          class_from_data = "Mangadex::#{object_type.split('_').collect(&:capitalize).join}"
          return unless Object.const_defined?(class_from_data)

          klass = Object.const_get(class_from_data)
          new(
            result: data['result'],
            response: data['response'],
            data: klass.from_data(data['data'] || data),
          )
        end

        def coerce_collection(data)
          new(
            result: data['result'],
            response: data['response'],
            limit: data['limit'],
            offset: data['offset'],
            total: data['total'],
            data: (
              Collection.new(
                data['data'].map do |entity_data|
                  object_type = entity_data['type']
                  class_from_data = "Mangadex::#{object_type.split('_').collect(&:capitalize).join}"
                  return unless Object.const_defined?(class_from_data)

                  klass = Object.const_get(class_from_data)
                  klass.from_data(entity_data)
                end
              )
            ),
          )
        end
      end

      def errored?
        Array(errors).any?
      end
    end
  end
end
