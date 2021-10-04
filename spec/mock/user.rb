# typed: ignore

module Mock
  class User
    def self.with_logged_in_user(&block)
      Interceptors::Mangadex.intercept do
        user = Mangadex::Api::User.new(
          mangadex_user_id: SecureRandom.uuid,
          session: SecureRandom.uuid,
          refresh: SecureRandom.uuid,
        )

        Mangadex.context.with_user(user) do
          yield(user)
        end
      end
    end
  end
end
