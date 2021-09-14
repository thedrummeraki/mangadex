require_relative "mangadex_object"

module Mangadex
  class Manga < MangadexObject
    include Internal::WithAttributes

    has_attributes \
      :title,
      :alt_titles,
      :description,
      :is_locked,
      :links,
      :original_language,
      :last_volume,
      :last_chapter,
      :publication_demographic,
      :status,
      :year,
      :content_rating,
      :tags,
      :version,
      :created_at,
      :updated_at

    def content_rating
      ContentRating.new(attributes.content_rating)
    end
  end
end
