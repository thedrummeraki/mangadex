# typed: true

module Mangadex
  module Errors
    # Standard error class for this gem.
    # 
    # @author thedrummeraki
    # @since 0.6.0
    class StandardError < ::StandardError
      extend T::Sig
    end

    class UserNotLoggedIn < StandardError
      sig { returns(String) }
      def message
        "You are not logged in. Use [Mangadex::Auth.login] to log in."
      end
    end

    class AuthenticationError < StandardError
      sig { returns(Mangadex::Api::Response) }
      attr_accessor :response

      sig { params(response: Mangadex::Api::Response).void }
      def initialize(response)
        @response = response
      end

      sig { returns(String) }
      def message
        "Your username or password may not be correct."
      end
    end

    class UnauthenticatedError < AuthenticationError
      sig { returns(String) }
      def message
        "Oops, are you logged in? Make sure you log in with Mangadex::Auth.login"
      end
    end
  end
end
