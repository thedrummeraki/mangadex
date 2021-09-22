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

  class UserNotLoggedIn < Error
    sig { returns(String) }
    def message
      "You are not logged in. Use [Mangadex::Auth.login] to log in."
    end
  end
end
