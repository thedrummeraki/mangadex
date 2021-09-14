require_relative "mangadex_object"

module Mangadex
  class CoverArt < MangadexObject
    has_attributes \
      :description,
      :volume,
      :file_name,
      :created_at,
      :updated_at,
      :version

    def image_url(size: :small)
      return unless manga.present?
      
      extension = case size
      when :large
        ''
      when :medium
        '.512.jpg'
      else # small by default
        '.256.jpg'
      end

      "https://uploads.mangadex.org/covers/#{manga.id}/#{file_name}#{extension}"
    end
  end
end
