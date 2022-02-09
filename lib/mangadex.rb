# typed: true
require 'sorbet-runtime'

require_relative 'extensions'
require "mangadex/utils"

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
require_relative "errors"

# Namespace for classes and modules for this gem.
# @since 5.3.0

module Mangadex
  class << self
    def configuration
      @configuration ||= Config.new
    end

    def context
      @context ||= Internal::Context.new
    end

    def configure(&block)
      yield(configuration)
    end

    def storage
      configuration.storage
    end

    def api_version
      context.version
    end
  end
end
