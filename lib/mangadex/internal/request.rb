# typed: false
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

      def self.get(path, params={}, auth: false, headers: nil, raw: false, content_rating: false)
        new(
          path_with_params(path, params, content_rating),
          method: :get,
          headers: headers,
          payload: nil,
        ).run!(raw: raw, auth: auth)
      end

      def self.post(path, headers: nil, auth: false, payload: nil, raw: false)
        new(path, method: :post, headers: headers, payload: payload).run!(raw: raw, auth: auth)
      end

      def self.put(path, headers: nil, auth: false, payload: nil, raw: false)
        new(path, method: :put, headers: headers, payload: payload).run!(raw: raw, auth: auth)
      end

      def self.delete(path, headers: nil, auth: false, payload: nil, raw: false)
        new(path, method: :delete, headers: headers, payload: payload).run!(raw: raw, auth: auth)
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

      def run!(raw: false, auth: false)
        payload_details = request_payload ? "Payload: #{request_payload}" : "{no-payload}"
        puts("[#{self.class.name}] #{method.to_s.upcase} #{request_url} #{payload_details}")

        raise Mangadex::UserNotLoggedIn.new if auth && Mangadex::Api::Context.user.nil?

        start_time = Time.now

        @response = request.execute
        end_time = Time.now
        elapsed_time = ((end_time - start_time) * 1000).to_i
        puts("[#{self.class.name}] took #{elapsed_time} ms")
        
        raw_request = raw || Mangadex::Api::Context.force_raw_requests

        if (body = @response.body)
          raw_request ? try_json(body) : Mangadex::Api::Response.coerce(try_json(body))
        end
      rescue RestClient::Unauthorized => error
        raise UnauthenticatedError.new(Mangadex::Api::Response.coerce(try_json(error.response.body)))
      rescue RestClient::Exception => error
        if (body = error.response.body)
          raw_request ? try_json(body) : Mangadex::Api::Response.coerce(JSON.parse(body)) rescue raise error
        else
          raise error
        end
      end

      private

      def self.path_with_params(path, params, content_rating)
        params = content_rating ? self.with_content_rating(params) : params
        return path if params.blank?

        params = params.deep_transform_keys do |key|
          key.to_s.camelize(:lower)
        end
        "#{path}?#{params.to_query}"
      end

      def self.with_content_rating(data)
        content_rating = data.has_key?(:content_rating) ? data[:content_rating] : []
        Mangadex::Api::Context.allow_content_ratings(*content_rating) do
          data[:content_rating] = Mangadex::Api::Context.allowed_content_ratings
        end
        data
      end

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

      def try_json(body)
        JSON.parse(body)
      rescue JSON::ParserError
        body
      end
    end
  end
end
