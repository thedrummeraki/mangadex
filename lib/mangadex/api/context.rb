module Mangadex
  module Api
    class Context
      @@user = nil

      class << self
        def user
          @@user&.with_valid_session
        end

        def user=(user)
          if user.is_a?(Mangadex::Api::User)
            @@user = user
          elsif user.is_a?(Mangadex::User)
            @@user = Mangadex::Api::User.new(
              user.id,
              data: user,
            )
          elsif user.is_a?(Hash)
            user = user.with_indifferent_access

            @@user = Mangadex::Api::User.new(
              user[:mangadex_user_id],
              session: user[:session],
              refresh: user[:refresh],
            )
          elsif user.nil?
            @@user = nil
          else
            raise ArgumentError, "Must be an instance of #{Mangadex::Api::User}, #{Mangadex::User} or Hash"
          end
        end

        def with_user(user)
          current_user = @@user
          @@user = user
          response = yield
          @@user = current_user
          response
        ensure
          @@user = current_user
        end

        def without_user
          with_user(nil) do
            yield
          end
        end
      end
    end
  end
end
