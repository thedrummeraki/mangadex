module Mock
  class User
    def self.with_logged_in_user(&block)
      Interceptors::Mangadex.intercept do
        user = Mangadex::Api::User.new(
          SecureRandom.uuid,
          session: SecureRandom.uuid,
          refresh: SecureRandom.uuid,
        )

        Mangadex::Api::Context.with_user(user) do
          yield(user)
        end
      end
    end
  end
end
