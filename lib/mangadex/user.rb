module Mangadex
  class User < MangadexObject
    has_attributes \
      :username,
      :roles,
      :version

    def self.inspect_attributes
      [:username, :roles]
    end
  end
end
