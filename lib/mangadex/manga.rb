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
        to_a = Mangadex::Internal::Definition.converts(:to_a)

        Mangadex::Internal::Request.get(
          '/manga',
          Mangadex::Internal::Definition.validate(args, {
            limit: { accepts: Integer },
            offset: { accepts: Integer },
            title: { accepts: String },
            authors: { accepts: [String] },
            artists: { accepts: [String] },
            year: { accepts: Integer },
            included_tags: { accepts: [String] },
            included_tags_mode: { accepts: %w(OR AND), converts: to_a },
            excluded_tags: { accepts: [String] },
            excluded_tags_mode: { accepts: %w(OR AND), converts: to_a },
            status: { accepts: %w(ongoing completed hiatus cancelled), converts: to_a },
            original_language: { accepts: [String] },
            excluded_original_language: { accepts: [String] },
            available_translated_language: { accepts: [String] },
            publication_demographic: { accepts: %w(shounen shoujo josei seinen none), converts: to_a },
            ids: { accepts: Array },
            content_rating: { accepts: %w(safe suggestive erotica pornographic), converts: to_a },
            created_at_since: { accepts: %r{^\d{4}-[0-1]\d-([0-2]\d|3[0-1])T([0-1]\d|2[0-3]):[0-5]\d:[0-5]\d$} },
            updated_at_since: { accepts: %r{^\d{4}-[0-1]\d-([0-2]\d|3[0-1])T([0-1]\d|2[0-3]):[0-5]\d:[0-5]\d$} },
            order: { accepts: Hash },
            includes: { accepts: Array, converts: to_a },
          }),
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
          Mangadex::Internal::Definition.validate(args, {
            translated_language: { accepts: Array },
            groups: { accepts: Array },
          }),
        )
      end
      alias_method :aggregate, :volumes_and_chapters

      def view(id, **args)
        Mangadex::Internal::Request.get(
          '/manga/%{id}' % {id: id},
          Mangadex::Internal::Definition.validate(args, {
            includes: { accepts: Array },
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
          Mangadex::Internal::Definition.chapter_list(args),
        )
      end

      def random(**args)
        Mangadex::Internal::Request.get(
          '/manga/random',
          Mangadex::Internal::Definition.validate(args, {
            includes: { accepts: Array },
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
          '/manga/status',
          Mangadex::Internal::Definition.validate({status: status}, {
            status: {
              accepts: %w(reading on_hold dropped plan_to_read re_reading completed),
              converts: Mangadex::Internal::Definition.converts(:to_a),
            },
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
          payload: Mangadex::Internal::Definition.validate({status: status}, {
            status: {
              accepts: %w(reading on_hold dropped plan_to_read re_reading completed),
              converts: Mangadex::Internal::Definition.converts(:to_a),
              required: true,
            },
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
