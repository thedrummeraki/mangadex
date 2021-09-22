# typed: true
module Mangadex
  class Tag < MangadexObject
    has_attributes :name, :description, :group, :version

    def self.attributes_to_inspect
      %i(name)
    end
  end
end
