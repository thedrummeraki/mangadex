# typed: true
module Mangadex
  module Internal
    class Context
      extend T::Sig

      sig { returns(T::Array[Mangadex::ContentRating]) }
      attr_accessor :allowed_content_ratings, :ignore_user

      def initialize
        @allowed_content_ratings = Mangadex.configuration.default_content_ratings
      end

      sig { returns(T.nilable(String)) }
      def version
        @version ||= Mangadex::Api::VersionChecker.check_mangadex_version
      end

      sig { returns(T.nilable(Mangadex::Api::User)) }
      def user
        @ignore_user ? nil : @user&.with_valid_session
      rescue Mangadex::Errors::UnauthorizedError
        warn("A user is present but not authenticated!")
        nil
      end

      sig { returns(T::Array[Mangadex::Tag]) }
      def tags
        @tags ||= Mangadex::Tag.list.data
      end

      sig { params(user: T.nilable(T.any(Hash, Mangadex::Api::User, Mangadex::User)), block: T.proc.returns(T.untyped)).returns(T.untyped) }
      def with_user(user, &block)
        temp_set_value("user", user) do
          yield
        end
      end

      sig { params(block: T.proc.returns(T.untyped)).returns(T.untyped) }
      def without_user(&block)
        temp_set_value("ignore_user", true) do
          yield
        end
      end

      sig { params(user: T.nilable(T.untyped)).void }
      def user=(user)
        if user.is_a?(Mangadex::Api::User)
          @user = user
        elsif user.is_a?(Mangadex::User)
          @user = Mangadex::Api::User.new(
            mangadex_user_id: user.id,
            data: user,
          )
        elsif user.is_a?(Hash)
          user = Mangadex::Internal::Definition.validate(user, {
            mangadex_user_id: { accepts: String, required: true },
            session: { accepts: String },
            refresh: { accepts: String },
          })

          @user = Mangadex::Api::User.new(
            mangadex_user_id: user[:mangadex_user_id],
            session: user[:session],
            refresh: user[:refresh],
          )
        elsif Mangadex::Context.user_object?(user)
          @user = Mangadex::Api::User.new(
            mangadex_user_id: user.mangadex_user_id.to_s,
            session: user.session,
            refresh: user.refresh,
            data: user,
          )
        elsif user.nil?
          @user = nil
        else
          raise TypeError, "Invalid user type."
        end
      end

      def allow_content_ratings(*content_ratings, &block)
        content_ratings = Mangadex::ContentRating.parse(Array(content_ratings))
        if block_given?
          content_ratings = Mangadex.context.allowed_content_ratings if content_ratings.empty?

          # set temporarily
          temp_set_value("allowed_content_ratings", content_ratings) do
            yield
          end
        elsif content_ratings.any?
          # set "permanently"
          @allowed_content_ratings = content_ratings
        else
          # This is to throw an exception prompting to pass a block if there no params.
          yield
        end
      end

      def with_allowed_content_ratings(*other_content_ratings, &block)
        T.unsafe(self).allow_content_ratings(*(allowed_content_ratings + other_content_ratings)) do
          yield
        end
      end

      # Only recommended for development and debugging only
      def force_raw_requests(&block)
        if block_given?
          temp_set_value("force_raw_requests", true) do
            yield
          end
        else
          !!@force_raw_requests
        end
      end

      def self.user_object?(user)
        return false if user.nil?

        missing_methods = [:session, :refresh, :mangadex_user_id] - user.methods
        return true if missing_methods.empty?

        warn("Potential user object #{user} is missing #{missing_methods}")
        false
      end

      private

      def temp_set_value(name, value, &block)
        setter_method_name = "#{name}="

        current_value = send(name)
        send(setter_method_name, value)
        response = yield
        send(setter_method_name, current_value)
        response
      ensure
        send(setter_method_name, current_value) if current_value
      end
    end
  end
end
