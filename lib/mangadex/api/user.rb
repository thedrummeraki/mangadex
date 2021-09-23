# typed: true
module Mangadex
  module Api
    class User
      extend T::Sig

      attr_accessor :mangadex_user_id, :session, :refresh, :session_valid_until
      attr_reader :data

      sig { params(mangadex_user_id: String, session: T.nilable(String), refresh: T.nilable(String), data: T.untyped).void }
      def initialize(mangadex_user_id, session: nil, refresh: nil, data: nil)
        raise ArgumentError, 'Missing mangadex_user_id' if mangadex_user_id.to_s.empty?

        @mangadex_user_id = mangadex_user_id
        @session = session
        @session_valid_until = session ? Time.now + (14 * 60) : nil
        @refresh = refresh
        @data = data
      end

      # true: The tokens were successfully refreshed
      # false: Error: refresh token empty or could not refresh the token on the server
      sig { returns(T::Boolean) }
      def refresh!
        return false if refresh.nil?

        response = Mangadex::Api::Context.without_user do
          Mangadex::Internal::Request.post('/auth/refresh', payload: { token: refresh })
        end
        return false unless response['token']

        @session_valid_until = Time.now + (14 * 60)
        @refresh = response.dig('token', 'refresh')
        @session = response.dig('token', 'session')

        true
      end

      sig { returns(Mangadex::Api::User) }
      def with_valid_session
        session_expired? && refresh!
        self
      ensure
        self
      end

      sig { returns(T::Boolean) }
      def session_expired?
        @session_valid_until.nil? || @session_valid_until <= Time.now
      end
    end
  end
end
