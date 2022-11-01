# typed: false
require 'rest-client'
require 'json'

module Mangadex
  module Internal
    class Request
      ALLOWED_METHODS = %i(get post put delete).freeze
      SENSITIVE_FIELDS = %w(password token oldPassword newPassword)

      attr_accessor :path, :headers, :payload, :method, :raw
      attr_reader :response

      def self.get(path, params={}, auth: false, headers: nil, raw: false, content_rating: false)
        new(
          path_with_params(path, params, content_rating),
          method: :get,
          headers: headers,
          payload: nil,
        ).run_with_info!(raw: raw, auth: auth)
      end

      def self.post(path, headers: nil, auth: false, payload: nil, raw: false)
        new(path, method: :post, headers: headers, payload: payload).run_with_info!(raw: raw, auth: auth)
      end

      def self.put(path, headers: nil, auth: false, payload: nil, raw: false)
        new(path, method: :put, headers: headers, payload: payload).run_with_info!(raw: raw, auth: auth)
      end

      def self.delete(path, headers: nil, auth: false, payload: nil, raw: false)
        new(path, method: :delete, headers: headers, payload: payload).run_with_info!(raw: raw, auth: auth)
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

      def run_with_info!(*args, **kwargs)
        measure_time_taken do
          run!(*args, **kwargs)
        end
      end

      def run!(raw: false, auth: false)
        raise Mangadex::Errors::UserNotLoggedIn.new if auth && Mangadex.context.user.nil?

        @response = request.execute
        raw_request = raw || Mangadex.context.force_raw_requests

        if (body = @response.body)
          raw_request ? try_json(body) : Mangadex::Api::Response.coerce(try_json(body))
        end
      rescue RestClient::Unauthorized => error
        raise Errors::UnauthorizedError.new(Mangadex::Api::Response.coerce(try_json(error.response.body)))
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
          Mangadex::Utils.camelize(key.to_s)
        end
        "#{path}?#{params.to_query}"
      end

      def self.with_content_rating(data)
        content_rating = data.has_key?(:content_rating) ? data[:content_rating] : []
        Mangadex.context.allow_content_ratings(*content_rating) do
          data[:content_rating] = Mangadex.context.allowed_content_ratings
        end
        data
      end

      def measure_time_taken(&block)
        payload_details = request_payload ? "Payload: #{sensitive_request_payload}" : "{no-payload}"
        puts("[#{self.class.name}] #{method.to_s.upcase} #{request_url} #{payload_details}")
        start_time = Time.now
        result = yield

        result
      ensure
        elapsed_time = ((Time.now - start_time) * 1000).to_i
        puts("[#{self.class.name}] took #{elapsed_time} ms")
      end

      def request_url
        request_path = path.start_with?('/') ? path : "/#{path}"
        "#{Mangadex.configuration.mangadex_url}#{request_path}"
      end

      def request_payload
        return if payload.nil? || payload.empty?

        JSON.generate(payload)
      end
      
      def sensitive_request_payload(sensitive_fields: SENSITIVE_FIELDS)
        payload = JSON.parse(request_payload)
        sensitive_fields.map(&:to_s).each do |field|
          payload[field] = '[REDACTED]' if payload.key?(field)
        end
        JSON.generate(payload)
      end

      def request_headers
        return headers if Mangadex.context.user.nil?

        headers.merge({
          Authorization: Mangadex.context.user.session,
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
