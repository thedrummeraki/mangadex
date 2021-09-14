require_relative "author"

module Mangadex
  class Artist < Author
    def artist?
      true
    end
  end
end
