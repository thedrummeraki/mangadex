# typed: true
module Mangadex
  module Api
    class Context
      extend T::Sig

      @@user = nil
      @@version = nil
      @@force_raw_requests = nil

      sig { returns(T.nilable(String)) }
      def self.version
        return @@version unless @@version.nil?

        @@version = Mangadex::Api::Version.check_mangadex_version
      end

      sig { returns(T.nilable(Mangadex::Api::User)) }
      def self.user
        @@user&.with_valid_session
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
          user = user.with_indifferent_access

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
        current_user = @@user
        @@user = user
        response = yield
        @@user = current_user
        response
      ensure
        @@user = current_user
      end

      sig { params(block: T.proc.returns(T.untyped)).returns(T.untyped) }
      def self.without_user(&block)
        with_user(nil) do
          yield
        end
      end

      def self.force_raw_requests(&block)
        if block_given?
          temp_force_raw_requests do
            yield
          end
        else
          !!@@force_raw_requests
        end
      end

      def self.force_raw_requests=(value)
        @@force_raw_requests = value
      end

      private

      def self.temp_force_raw_requests(&block)
        current_force_raw_requests = @@force_raw_requests
        @@force_raw_requests = true
        response = yield
        @@force_raw_requests = current_force_raw_requests
        response
      ensure
        @@force_raw_requests = current_force_raw_requests
      end
    end
  end
end
