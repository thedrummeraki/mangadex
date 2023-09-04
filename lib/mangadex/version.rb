# typed: false
module Mangadex
  module Version
    MAJOR = "5"
    MINOR = "10"
    TINY = "0"
    PATCH = "1"

    STRING = [MAJOR, MINOR, TINY].compact.join('.')
    FULL = [MAJOR, MINOR, TINY, PATCH].compact.join('.')
  end
end
