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
      def list(**args)
        Mangadex::Internal::Request.get('/manga', args)
      end

      def create(**args)
      end

      def volumes_and_chapters(**args)
      end

      def view(id, includes: nil)
        Mangadex::Internal::Request.get('/manga/%{id}' % {id: id}, {includes: includes})
      end

      def update(id)
      end

      def delete(id)
      end

      def unfollow(id)
      end

      def follow(id)
      end

      def feed(id, **args)
      end

      def random(**args)
      end

      def tag_list
      end

      def reading_status(id)
      end

      def all_reading_status(**args)
      end

      def update_reading_status(id, status:)
      end
    end

    def content_rating
      attributes&.content_rating.presence && ContentRating.new(attributes.content_rating)
    end

    def self.attributes_to_inspect
      [:id, :type, :title, :content_rating, :original_language, :year]
    end
  end
end
