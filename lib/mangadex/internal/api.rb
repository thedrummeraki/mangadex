require 'rest-client'
require 'json'

module Mangadex
  module Internal
    class Api
      BASE_URI = 'https://api.mangadex.org'
      ALLOWED_METHODS = %i(get post put).freeze

      attr_accessor :path, :headers, :payload, :method, :raw
      attr_reader :response

      class << self
        def get(path, convert_to_class=nil, headers: nil)
          new(path, method: :get, headers: headers, payload: nil).run!
        end

        def post(path, headers: nil, payload: nil)
          new(path, method: :post, headers: headers, payload: payload).run!
        end

        def put(path, headers: nil, payload: nil)
          new(path, method: :put, headers: headers, payload: payload).run!
        end
      end

      def initialize(path, method:, headers: nil, payload: nil)
        @path = path
        @headers = Hash(headers)
        @payload = payload
        @method = ensure_method!(method)
      end

      def request
        RestClient::Request.new(
          method: method,
          url: request_url,
          headers: headers,
          payload: request_payload,
        )
      end

      def run!
        # Rails.logger.info("[#{self.class.name}] #{method.to_s.upcase} #{request_url}")
        start_time = Time.now

        @response = request.execute
        end_time = Time.now
        elapsed_time = ((end_time - start_time) * 1000).to_i
        # Rails.logger.info("[#{self.class.name}] took #{elapsed_time} ms")

        JSON.parse(@response.body) if @response.body
      end

      private

      def request_url
        request_path = path.start_with?('/') ? path : "/#{path}"
        "#{BASE_URI}#{request_path}"
      end

      def request_payload
        return unless payload.nil? || payload.empty?

        JSON.generate(payload)
      end

      def missing_method?(method)
        method.nil? || method.to_s.strip.empty?
      end

      def ensure_method!(method)
        raise 'Method must be present' if missing_method?(method)

        clean_method = method.to_s.downcase.to_sym
        return clean_method if ALLOWED_METHODS.include?(clean_method)

        raise "Invalid method: #{method}. Must be one of: #{ALLOWED_METHODS}"
      end
    end
  end
end
