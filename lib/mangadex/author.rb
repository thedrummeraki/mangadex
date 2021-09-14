require_relative "mangadex_object"

module Mangadex
  class Author < MangadexObject
    has_attributes :name, :image_url, :biography, :version, :created_at, :updated_at

    def self.inspect_attributes
      [:name]
    end

    def artist?
      false
    end
  end
end