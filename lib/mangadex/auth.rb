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

      session = response.dig('token', 'session')
      refresh = response.dig('token', 'refresh')

      mangadex_user = Mangadex::Internal::Request.get('/user/me', headers: { Authorization: session })

      user = Mangadex::Api::User.new(
        mangadex_user_id: mangadex_user.data.id,
        session: session,
        refresh: refresh,
        data: mangadex_user.data,
      )
      return if user.session_expired?

      Mangadex.context.user = user

      user.persist
      user
    rescue Errors::UnauthenticatedError => error
      raise Errors::AuthenticationError.new(error.response)
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
      return true if Mangadex.context.user.nil?

      response = Mangadex::Internal::Request.post(
        '/auth/logout',
      )
      return reponse if response.is_a?(Mangadex::Api::Response) && response.errored?

      if Mangadex.context.user.respond_to?(:session=)
        Mangadex.context.user.session = nil
      end
      if Mangadex.context.user.respond_to?(:refresh=)
        Mangadex.context.user.refresh = nil
      end
      Mangadex.storage.clear(Mangadex.context.user.mangadex_user_id)
      Mangadex.context.user = nil
      true
    end

    sig { returns(T::Boolean) }
    def self.refresh_token
      !(Mangadex.context.user&.refresh!).nil?
    end
  end
end
