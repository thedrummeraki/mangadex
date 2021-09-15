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
        Mangadex::Internal::Request.get(
          '/manga',
          Mangadex::Internal::Definition.manga_list(args),
        )
      end

      def create(**args)
        Mangadex::Internal::Request.post('/manga', payload: args)
      end

      def update(id, **args)
        Mangadex::Internal::Request.put('/manga/%{id}' % {id: id}, payload: args)
      end

      def volumes_and_chapters(id, **args)
        Mangadex::Internal::Request.get(
          '/manga/%{id}/aggregate' % {id: id},
          Mangadex::Internal::Definition.ensure_params(args, {
            translated_language: Array,
            groups: Array,
          }),
        )
      end
      alias_method :aggregate, :volumes_and_chapters

      def view(id, **args)
        Mangadex::Internal::Request.get(
          '/manga/%{id}' % {id: id},
          Mangadex::Internal::Definition.ensure_params(args, {
            includes: Array,
          })
        )
      end

      def delete(id)
        Mangadex::Internal::Request.delete(
          '/manga/%{id}' % {id: id},
        )
      end

      def unfollow(id)
        Mangadex::Internal::Request.delete(
          '/manga/%{id}/unfollow' % {id: id},
        )
      end

      def follow(id)
        Mangadex::Internal::Request.post(
          '/manga/%{id}/follow' % {id: id},
        )
      end

      def feed(id, **args)
        Mangadex::Internal::Request.get(
          '/manga/%{id}/feed' % {id: id},
          Mangadex::Internal::Definition.manga_feed(args),
        )
      end

      def random(**args)
        Mangadex::Internal::Request.get(
          '/manga/random',
          Mangadex::Internal::Definition.ensure_params(args, {
            includes: Array,
          })
        )
      end

      def tag_list
        Mangadex::Internal::Request.get(
          '/manga/tag'
        )
      end

      def reading_status(**args)
        Mangadex::Internal::Request.get(
          '/manga/status' % {id: id},
          Mangadex::Internal::Definition.ensure_params({status: status}, {
            status: {value: %w(reading on_hold dropped plan_to_read re_reading completed)},
          })
        )
      end

      def all_reading_status(id)
        Mangadex::Internal::Request.get(
          '/manga/%{id}/status' % {id: id},
        )
      end

      def update_reading_status(id, status)
        Mangadex::Internal::Request.post(
          '/manga/%{id}/status' % {id: id},
          payload: Mangadex::Internal::Definition.ensure_params({status: status}, {
            status: {value: %w(reading on_hold dropped plan_to_read re_reading completed), required: true},
          })
        )
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
