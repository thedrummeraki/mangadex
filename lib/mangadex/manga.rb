require_relative "mangadex_object"

module Mangadex
  class Manga < MangadexObject
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

    class << self
      def attributes_to_inspect
        [:id, :type, :title, :content_rating, :original_language, :year]
      end
    end

    def content_rating
      attributes&.content_rating.presence && ContentRating.new(attributes.content_rating)
    end
  end
end
