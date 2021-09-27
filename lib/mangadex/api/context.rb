# typed: true
module Mangadex
  module Api
    class Context
      extend T::Sig

      DEFAULT_MANGADEX_CONTENT_RATING_VALUES = [
        ContentRating::SAFE,
        ContentRating::SUGGESTIVE,
        ContentRating::EROTICA,
      ].freeze

      @@user = nil
      @@version = nil
      @@force_raw_requests = nil
      @@tags = nil
      @@allowed_content_ratings = DEFAULT_MANGADEX_CONTENT_RATING_VALUES

      sig { returns(T.nilable(String)) }
      def self.version
        return @@version unless @@version.nil?

        @@version = Mangadex::Api::VersionChecker.check_mangadex_version
      end

      sig { returns(T.nilable(Mangadex::Api::User)) }
      def self.user
        @@user&.with_valid_session
      end

      sig { returns(T::Array[Mangadex::Tag]) }
      def self.tags
        return @@tags if @@tags

        @@tags = Mangadex::Tag.list.data
      end

      sig { returns(T::Array[Mangadex::ContentRating]) }
      def self.allowed_content_ratings
        @@allowed_content_ratings.map { |value| ContentRating.new(value) }
      end

      sig { params(user: T.nilable(T.any(Hash, Mangadex::Api::User, Mangadex::User))).void }
      def self.user=(user)
        if user.is_a?(Mangadex::Api::User)
          @@user = user
        elsif user.is_a?(Mangadex::User)
          @@user = Mangadex::Api::User.new(
            user.id,
            data: user,
          )
        elsif user.is_a?(Hash)
          user = Mangadex::Internal::Definition.validate(user, {
            mangadex_user_id: { accepts: String, required: true },
            session: { accepts: String },
            refresh: { accepts: String },
          })

          @@user = Mangadex::Api::User.new(
            user[:mangadex_user_id],
            session: user[:session],
            refresh: user[:refresh],
          )
        elsif user.nil?
          @@user = nil
        end
      end

      sig { params(user: T.nilable(T.any(Hash, Mangadex::Api::User, Mangadex::User)), block: T.proc.returns(T.untyped)).returns(T.untyped) }
      def self.with_user(user, &block)
        temp_set_value("user", user) do
          yield
        end
      end

      sig { params(block: T.proc.returns(T.untyped)).returns(T.untyped) }
      def self.without_user(&block)
        with_user(nil) do
          yield
        end
      end

      def self.force_raw_requests(&block)
        if block_given?
          temp_set_value("force_raw_requests", true) do
            yield
          end
        else
          !!@@force_raw_requests
        end
      end

      def self.force_raw_requests=(value)
        @@force_raw_requests = value
      end

      def self.allow_content_ratings(*content_ratings, &block)
        content_ratings = if content_ratings.empty?
          allowed_content_ratings
        else
          Mangadex::ContentRating.parse(content_ratings)
        end
        if block_given?
          # set temporarily
          temp_set_value("allowed_content_ratings", content_ratings) do
            yield
          end
        elsif content_ratings.any?
          # set "permanently"
          @@allowed_content_ratings = content_ratings
        else
          # This is to throw an exception prompting to pass a block if there no params.
          yield
        end
      end

      def self.with_allowed_content_ratings(*other_content_ratings, &block)
        T.unsafe(self).allow_content_ratings(*(allowed_content_ratings + other_content_ratings)) do
          yield
        end
      end

      private

      def self.temp_set_value(name, value, &block)
        var_name = "@@#{name}"
        current_value = class_variable_get(var_name)
        class_variable_set(var_name, value)
        response = yield
        class_variable_set(var_name, current_value)
        response
      ensure
        class_variable_set(var_name, current_value) if current_value
      end
    end
  end
end
