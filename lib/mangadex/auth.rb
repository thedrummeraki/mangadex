# typed: false
module Mangadex
  class Auth
    extend T::Sig

    sig { params(username: T.nilable(String), email: T.nilable(String), password: String).returns(T.nilable(Mangadex::Api::User)) }
    def self.login(username: nil, email: nil, password: nil)
      args = { password: password }
      args.merge!(email: email) if email
      args.merge!(username: username) if username

      response = Mangadex::Internal::Request.post(
        '/auth/login',
        payload: Mangadex::Internal::Definition.validate(args, {
          username: { accepts: String },
          email: { accepts: String },
          password: { accepts: String, required: true },
        }),
      )

      raise AuthenticationError.new(response) if response.is_a?(Mangadex::Api::Response) && response.errored?

      session = response.dig('token', 'session')
      refresh = response.dig('token', 'refresh')

      mangadex_user = Mangadex::Internal::Request.get('/user/me', headers: { Authorization: session })

      user = Mangadex::Api::User.new(
        mangadex_user.data.id,
        session: session,
        refresh: refresh,
        data: mangadex_user.data,
      )
      return if user.session_expired?

      user.persist
      user
    end

    sig { returns(Hash) }
    def self.check_token
      JSON.parse(
        Mangadex::Internal::Request.get(
          '/auth/check',
          raw: true,
        )
      )
    end

    sig { returns(T.any(T::Boolean, Mangadex::Api::Response)) }
    def self.logout
      return true if Mangadex::Api::Context.user.nil?

      response = Mangadex::Internal::Request.post(
        '/auth/logout',
      )
      return reponse if response.is_a?(Mangadex::Api::Response) && response.errored?

      if Mangadex::Api::Context.user.respond_to(:session=)
        Mangadex::Api::Context.user.session = nil
      end
      Mangadex.storage.clear(Mangadex::Api::Context.user.mangadex_user_id)
      Mangadex::Api::Context.user = nil
      true
    end

    sig { returns(T::Boolean) }
    def self.refresh_token
      !(Mangadex::Api::Context.user&.refresh!).nil?
    end
  end
end
