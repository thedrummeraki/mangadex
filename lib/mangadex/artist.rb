# typed: true
require_relative "author"

module Mangadex
  class Artist < Author
    # Indicates if this is an artist
    #
    # @return [Boolean] whether this is an artist or not.
    def artist?
      true
    end
  end
end
