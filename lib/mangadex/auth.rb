module Mangadex
  class Auth
    class << self
      def login(username, password)
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
        Mangadex::Api::Context.user = user
        !user.session_expired?
      end

      def logout
      end
    end
  end
end
