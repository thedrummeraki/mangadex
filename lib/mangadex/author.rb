require_relative "mangadex_object"

module Mangadex
  class Author < MangadexObject
    include Internal::WithAttributes

    has_attributes :name, :image_url, :biography, :version, :created_at, :updated_at

    def artist?
      false
    end
  end
end