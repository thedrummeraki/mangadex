# typed: true
module Mangadex
  module Api
    class User
      extend T::Sig

      attr_accessor :mangadex_user_id, :session, :refresh, :session_valid_until
      attr_reader :data

      SERIALIZABLE_KEYS = %i(
        mangadex_user_id
        session
        refresh
        session_valid_until
      )

      sig { params(mangadex_user_id: String, session: T.nilable(String), refresh: T.nilable(String), data: T.untyped, session_valid_until: T.nilable(Time)).void }
      def initialize(mangadex_user_id:, session: nil, refresh: nil, data: nil, session_valid_until: nil)
        raise ArgumentError, 'Missing mangadex_user_id' if mangadex_user_id.to_s.empty?

        @mangadex_user_id = mangadex_user_id
        @session = session
        @session_valid_until = session_valid_until ? session_valid_until : (session ? Time.now + (14 * 60) : nil)
        @refresh = refresh
        @data = data
      end

      # true: The tokens were successfully refreshed
      # false: Error: refresh token empty or could not refresh the token on the server
      sig { params(block: T.nilable(T.proc.returns(T.untyped))).returns(T::Boolean) }
      def refresh!(&block)
        return false if refresh.nil?

        response = Mangadex::Internal::Request.post('/auth/refresh', payload: { token: refresh })
        return false unless response['token']

        @session_valid_until = Time.now + (14 * 60)
        @refresh = response.dig('token', 'refresh')
        @session = response.dig('token', 'session')

        if block_given?
          yield(self)
        end

        true
      end

      # callbacks
      def on_login
        yield
      end

      def on_logout
        yield
      end

      sig { returns(T::Boolean) }
      def session_expired?
        @session_valid_until.nil? || @session_valid_until <= Time.now
      end

      sig { returns(T::Boolean) }
      def persist
        return false unless valid?

        Mangadex.storage.set(mangadex_user_id, 'session', session) if session
        Mangadex.storage.set(mangadex_user_id, 'refresh', refresh) if refresh
        if session_valid_until
          Mangadex.storage.set(mangadex_user_id, 'session_valid_until', session_valid_until.to_s)
        end

        true
      end

      sig { returns(T::Boolean) }
      def valid?
        !mangadex_user_id.nil? && !mangadex_user_id.strip.empty?
      end

      sig { params(except: T.any(Symbol, T::Array[Symbol])).returns(Hash) }
      def to_h(except: [])
        except = Array(except).map(&:to_sym)
        keys = SERIALIZABLE_KEYS.reject do |key|
          except.include?(key)
        end

        keys.map do |key|
          [key, send(key)]
        end.to_h
      end

      sig { params(mangadex_user_id: T.nilable(String)).returns(T.nilable(User)) }
      def self.from_storage(mangadex_user_id)
        return if mangadex_user_id.nil?

        session = Mangadex.storage.get(mangadex_user_id, 'session')
        refresh = Mangadex.storage.get(mangadex_user_id, 'refresh')
        session_valid_until = Mangadex.storage.get(mangadex_user_id, 'session_valid_until')

        user = if session || refresh || session_valid_until
          session_valid_until = session_valid_until ? Time.parse(session_valid_until) : nil

          new(
            mangadex_user_id: mangadex_user_id,
            session: session,
            refresh: refresh,
            session_valid_until: session_valid_until,
          )
        else
          nil
        end

        if user
          Mangadex.context.user = user
        end

        user
      end
    end
  end
end
