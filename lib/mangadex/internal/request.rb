require 'rest-client'
require 'json'
require 'active_support/core_ext/object/to_query'
require 'active_support/core_ext/hash/keys'

module Mangadex
  module Internal
    class Request
      BASE_URI = 'https://api.mangadex.org'
      ALLOWED_METHODS = %i(get post put delete).freeze

      attr_accessor :path, :headers, :payload, :method, :raw
      attr_reader :response

      class << self
        def get(path, params={}, headers: nil, raw: false)
          new(path_with_params(path, params), method: :get, headers: headers, payload: nil).run!(raw: raw)
        end

        def post(path, headers: nil, payload: nil, raw: false)
          new(path, method: :post, headers: headers, payload: payload).run!(raw: raw)
        end

        def put(path, headers: nil, payload: nil, raw: false)
          new(path, method: :put, headers: headers, payload: payload).run!(raw: raw)
        end

        def delete(path, headers: nil, payload: nil, raw: false)
          new(path, method: :delete, headers: headers, payload: payload).run!(raw: raw)
        end
        
        private

        def path_with_params(path, params)
          return path if params.blank?

          params = params.deep_transform_keys do |key|
            key.to_s.camelize(:lower)
          end
          "#{path}?#{params.to_query}"
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
          headers: request_headers,
          payload: request_payload,
        )
      end

      def run!(raw: false)
        payload_details = request_payload ? "Payload: #{request_payload}" : "{no-payload}"
        puts("[#{self.class.name}] #{method.to_s.upcase} #{request_url} #{payload_details}")
        start_time = Time.now

        @response = request.execute
        end_time = Time.now
        elapsed_time = ((end_time - start_time) * 1000).to_i
        puts("[#{self.class.name}] took #{elapsed_time} ms")

        if @response.body
          raw ? @response.body : Mangadex::Api::Response.coerce(JSON.parse(@response.body))
        end
      rescue RestClient::Exception => error
        if error.response.body
          raw ? error.response.body : Mangadex::Api::Response.coerce(JSON.parse(error.response.body))
        else
          raise error
        end
      end

      private

      def request_url
        request_path = path.start_with?('/') ? path : "/#{path}"
        "#{BASE_URI}#{request_path}"
      end

      def request_payload
        return if payload.nil? || payload.empty?

        JSON.generate(payload)
      end

      def request_headers
        return headers if Mangadex::Api::Context.user.nil?

        headers.merge({
          Authorization: Mangadex::Api::Context.user.with_valid_session.session,
        })
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
