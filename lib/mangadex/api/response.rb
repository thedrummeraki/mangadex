# typed: true
module Mangadex
  module Api
    class Response < Mangadex::MangadexObject
      extend T::Sig
      extend T::Generic

      attr_accessor :result, :response, :errors, :data
      attr_accessor :limit, :offset, :total
      attr_accessor :raw_data

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

      sig { params(data: Hash).returns(T.any(Mangadex::Api::Response, Hash)) }
      def self.coerce(data)
        if data['errors']
          coerce_errors(data)
        elsif data['response'] == 'entity'
          coerce_entity(data)
        elsif data['response'] == 'collection'
          coerce_collection(data)
        elsif data.keys.include?('statistics')
          coerce_statistics(data)
        else
          data
        end
      end

      def errored?(status=nil)
        errored = Array(errors).any?
        return errored if status.nil?

        errors.select { |error| error.status.to_s == status.to_s }.any?
      end

      def more_results?
        return unless data.is_a?(Array)

        total > data.count
      end

      def count
        data.is_a?(Array) ? data.count : nil
      end
      alias_method :size, :count
      alias_method :length, :count

      def each(&block)
        if data.is_a?(Array)
          data.each(&block)
        else
          raise ArgumentError, "Expect data to be Array, but got #{data.class}"
        end
      end

      def to_a
        each.to_a
      end

      def first
        to_a.first
      end

      def last
        to_a.last
      end

      def as_json(*)
        Hash(raw_data)
      end

      private

      def self.coerce_errors(data)
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
          raw_data: data,
        )
      end

      def self.coerce_entity(data)
        object_type = data['type'] || data.dig('data', 'type')

        # Derive the class name from the type. "Convention over configuration"
        class_from_data = "Mangadex::#{object_type.split('_').collect(&:capitalize).join}"
        return unless Object.const_defined?(class_from_data)

        klass = Object.const_get(class_from_data)
        new(
          result: data['result'],
          response: data['response'],
          data: klass.from_data(data['data'] || data),
          raw_data: data,
        )
      end

      def self.coerce_collection(data)
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
          raw_data: data,
        )
      end

      def self.coerce_statistics(data)
        new(
          result: data['result'],
          data: Mangadex::Statistic.from_data(data['statistics']),
        )
      end
    end
  end
end
