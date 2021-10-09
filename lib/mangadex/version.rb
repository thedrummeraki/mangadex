# typed: false
module Mangadex
  module Version
    MAJOR = "5"
    MINOR = "3"
    TINY = "3"
    PATCH = "3"

    STRING = [MAJOR, MINOR, TINY].compact.join('.')
    FULL = [MAJOR, MINOR, TINY, PATCH].compact.join('.')
  end
end
