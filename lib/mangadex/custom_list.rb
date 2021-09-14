require_relative "mangadex_object"

module Mangadex
  class CustomList < MangadexObject
    has_attributes \
      :name,
      :visibility,
      :version
  end
end

