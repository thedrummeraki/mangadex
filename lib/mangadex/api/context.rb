module Mangadex
  module Api
    class Context
      @@user = nil

      class << self
        def user
          @@user
        end

        def user=(user)
          if user.is_a?(Mangadex::Api::User)
            @@user = user
          elsif user.is_a?(Mangadex::User)
            @@user = Mangadex::Api::User.new(
              mangadex_user_id: user.id,
            )
          elsif user.is_a?(Hash)
            user = user.with_indifferent_access

            @@user = Mangadex::Api::User.new(
              user[:mangadex_user_id],
              session: user[:session],
              refresh: user[:refresh],
            )
          else
            raise ArgumentError, "Must be an instance of #{Mangadex::Api::User}, #{Mangadex::User} or Hash"
          end
        end

        def with_user(user)
          current_user = self.user
          self.user = user
          yield
        ensure
          self.user = current_user
        end
      end
    end
  end
end
