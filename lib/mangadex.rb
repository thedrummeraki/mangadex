# typed: strict
require 'sorbet-runtime'

require 'active_support'
require_relative 'extensions'

# The insides of the gem
require "mangadex/version"
require "mangadex/internal"

# Types that represent all of the resources (ie: objects)
require "mangadex/types"

# API, to interact with Mangadex
require "mangadex/api"

# Persist strategies
require "mangadex/storage"

require_relative "config"

# Namespace for classes and modules for this gem.
# @since 5.3.0

module Mangadex
  # Standard error class for this gem.
  # 
  # @author thedrummeraki
  # @since 0.6.0
  class Error < StandardError
    extend T::Sig
  end

  class << self
    def configuration
      @configuration ||= Config.new
    end

    def context
      @context ||= Api::Context.new
    end

    def configure(&block)
      yield(configuration)
    end

    def storage
      configuration.storage
    end

    def api_version
      context.check_mangadex_version
    end
  end

  class UserNotLoggedIn < Error
    sig { returns(String) }
    def message
      "You are not logged in. Use [Mangadex::Auth.login] to log in."
    end
  end

  class AuthenticationError < Error
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
