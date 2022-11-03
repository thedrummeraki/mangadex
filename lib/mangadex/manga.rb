# typed: true
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
      :state,
      :version,
      :chapter_numbers_reset_on_new_volume,
      :available_translated_languages,
      :latest_uploaded_chapter,
      :created_at,
      :updated_at

    sig { params(args: T::Api::Arguments).returns(T::Api::MangaResponse) }
    def self.list(**args)
      to_a = Mangadex::Internal::Definition.converts(:to_a)

      Mangadex::Internal::Request.get(
        '/manga',
        Mangadex::Internal::Definition.validate(args, {
          limit: { accepts: Integer },
          offset: { accepts: Integer },
          title: { accepts: String },
          author_or_artist: { accepts: String },
          authors: { accepts: [String] },
          artists: { accepts: [String] },
          year: { accepts: Integer },
          included_tags: { accepts: [String] },
          included_tags_mode: { accepts: %w(OR AND) },
          excluded_tags: { accepts: [String] },
          excluded_tags_mode: { accepts: %w(OR AND) },
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
          has_available_chapters: { accepts: ['0', '1', 'true', 'false'] },
          group: { accepts: String },
        }),
        content_rating: true,
      )
    end

    sig { params(id: String, args: T::Api::Arguments).returns(Hash) }
    def self.volumes_and_chapters(id, **args)
      Mangadex::Internal::Request.get(
        '/manga/%{id}/aggregate' % {id: id},
        Mangadex::Internal::Definition.validate(args, {
          translated_language: { accepts: Array },
          groups: { accepts: Array },
        }),
      )
    end

    sig { params(id: String, args: T::Api::Arguments).returns(T::Api::MangaResponse) }
    def self.view(id, **args)
      to_a = Mangadex::Internal::Definition.converts(:to_a)
      Mangadex::Internal::Definition.must(id)

      Mangadex::Internal::Request.get(
        '/manga/%{id}' % {id: id},
        Mangadex::Internal::Definition.validate(args, {
          includes: { accepts: Array, converts: to_a },
        })
      )
    end

    sig { params(id: String).returns(T.any(Hash, Mangadex::Api::Response)) }
    def self.unfollow(id)
      Mangadex::Internal::Definition.must(id)

      Mangadex::Internal::Request.delete(
        '/manga/%{id}/follow' % {id: id},
      )
    end

    sig { params(id: String).returns(T.any(Hash, Mangadex::Api::Response)) }
    def self.follow(id)
      Mangadex::Internal::Definition.must(id)

      Mangadex::Internal::Request.post(
        '/manga/%{id}/follow' % {id: id},
      )
    end

    sig { params(id: String, args: T::Api::Arguments).returns(T::Api::ChapterResponse) }
    def self.feed(id, **args)
      Mangadex::Internal::Definition.must(id)

      Mangadex::Internal::Request.get(
        '/manga/%{id}/feed' % {id: id},
        Mangadex::Internal::Definition.chapter_list(args),
        content_rating: true,
      )
    end

    sig { params(args: T::Api::Arguments).returns(T::Api::MangaResponse) }
    def self.random(**args)
      to_a = Mangadex::Internal::Definition.converts(:to_a)

      Mangadex::Internal::Request.get(
        '/manga/random',
        Mangadex::Internal::Definition.validate(args, {
          includes: { accepts: Array },
          content_rating: { accepts: %w(safe suggestive erotica pornographic), converts: to_a },
          included_tags: { accepts: [String] },
          included_tags_mode: { accepts: %w(OR AND) },
          excluded_tags: { accepts: [String] },
          excluded_tags_mode: { accepts: %w(OR AND) },
        })
      )
    end

    sig { returns(Mangadex::Api::Response[Mangadex::Tag]) }
    def self.tag_list
      Mangadex::Internal::Request.get(
        '/manga/tag'
      )
    end

    sig { params(status: T.nilable(String)).returns(T::Api::GenericResponse) }
    def self.all_reading_status(status = nil)
      args = { status: status } if status.present?

      Mangadex::Internal::Request.get(
        '/manga/status',
        Mangadex::Internal::Definition.validate(args, {
          status: {
            accepts: %w(reading on_hold dropped plan_to_read re_reading completed),
            converts: :to_s,
          },
        })
      )
    end

    sig { params(id: String).returns(T::Api::GenericResponse) }
    def self.reading_status(id)
      Mangadex::Internal::Definition.must(id)

      Mangadex::Internal::Request.get(
        '/manga/%{id}/status' % {id: id},
      )
    end

    sig { params(id: String, status: String).returns(T::Api::GenericResponse) }
    def self.update_reading_status(id, status)
      Mangadex::Internal::Definition.must(id)

      Mangadex::Internal::Request.post(
        '/manga/%{id}/status' % {id: id},
        payload: Mangadex::Internal::Definition.validate({status: status}, {
          status: {
            accepts: %w(reading on_hold dropped plan_to_read re_reading completed),
            required: true,
          },
        })
      )
    end

    sig { params(id: T.any(T::Array[String], String), grouped: T::Boolean).returns(T::Api::GenericResponse) }
    def self.read_markers(id, grouped: false)
      Mangadex::Internal::Request.get(
        '/manga/read',
        { ids: Array(id), grouped: grouped },
        auth: true,
      )
    end

    # Untested API endpoints
    sig { params(id: String, args: T::Api::Arguments).returns(T::Api::MangaResponse) }
    def self.update(id, **args)
      Mangadex::Internal::Definition.must(id)

      Mangadex::Internal::Request.put('/manga/%{id}' % {id: id}, payload: args)
    end

    sig { params(id: String).returns(Hash) }
    def self.delete(id)
      Mangadex::Internal::Definition.must(id)

      Mangadex::Internal::Request.delete(
        '/manga/%{id}' % {id: id},
      )
    end

    def self.create(**args)
      Mangadex::Internal::Request.post('/manga', payload: args)
    end

    def self.attributes_to_inspect
      [:id, :type, :title, :content_rating, :original_language, :year]
    end

    class << self
      alias_method :aggregate, :volumes_and_chapters
      alias_method :get, :view
      alias_method :edit, :update
    end

    sig { returns(T.nilable(ContentRating)) }
    def content_rating
      return unless attributes&.content_rating.present?

      ContentRating.new(attributes.content_rating)
    end

    sig { params(args: T::Api::Arguments).returns(Mangadex::Api::Response[Chapter]) }
    def chapters(**args)
      chapter_args = args.merge({manga: id})
      Chapter.list(**chapter_args)
    end
  end
end
