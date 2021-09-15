require 'active_support'
require_relative 'extensions'

# The insides of the gem
require "mangadex/version"
require "mangadex/internal"

# Types that represent all of the resources (ie: objects)
require "mangadex/types"

# API, to interact with Mangadex
require "mangadex/api"

module Mangadex
  class Error < StandardError; end
  # Your code goes here...
end
