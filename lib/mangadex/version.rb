# typed: false
module Mangadex
  module Version
    MAJOR = "5"
    MINOR = "4"
    TINY = "15"
    PATCH = nil

    STRING = [MAJOR, MINOR, TINY].compact.join('.')
    FULL = [MAJOR, MINOR, TINY, PATCH].compact.join('.')
  end
end
