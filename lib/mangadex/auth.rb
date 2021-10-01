# typed: false
module Mangadex
  class Auth
    extend T::Sig

    sig { params(username: String, password: String).returns(T.any(T.nilable(Mangadex::Api::User), Mangadex::Api::Response)) }
    def self.login(username, password)
      response = Mangadex::Internal::Request.post(
        '/auth/login',
        payload: {
          username: username,
          password: password,
        },
      )
      return response if response.is_a?(Mangadex::Api::Response) && response.errored?

      session = response.dig('token', 'session')
      refresh = response.dig('token', 'refresh')

      mangadex_user = Mangadex::Internal::Request.get('/user/me', headers: { Authorization: session })

      user = Mangadex::Api::User.new(
        mangadex_user.data.id,
        session: session,
        refresh: refresh,
        data: mangadex_user.data,
      )
      !user.session_expired? ? user : nil
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

      Mangadex::Api::Context.user = nil
      true
    end

    sig { returns(T::Boolean) }
    def self.refresh_token
      !(Mangadex::Api::Context.user&.refresh!).nil?
    end
  end
end
