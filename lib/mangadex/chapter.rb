# typed: false
require_relative "mangadex_object"

module Mangadex
  class Chapter < MangadexObject
    include Internal::WithAttributes

    has_attributes \
      :title,
      :volume,
      :chapter,
      :translated_language,
      :hash,
      :data,
      :data_saver,
      :last_chapter,
      :uploader,
      :external_url,
      :version,
      :created_at,
      :updated_at,
      :publish_at

    sig { params(args: T::Api::Arguments).returns(Mangadex::Api::Response[Chapter]) }
    def self.list(**args)
      Mangadex::Internal::Request.get(
        '/chapter',
        Mangadex::Internal::Definition.chapter_list(args),
      )
    end

    sig { params(id: String, args: T::Api::Arguments).returns(Mangadex::Api::Response[Chapter]) }
    def self.get(id, **args)
      Mangadex::Internal::Definition.must(id)

      Mangadex::Internal::Request.get(
        '/chapter/%{id}' % {id: id},
        Mangadex::Internal::Definition.validate(args, {
          includes: { accepts: [String] },
        }),
      )
    end

    sig { params(id: String, args: T::Api::Arguments).returns(Mangadex::Api::Response[Chapter]) }
    def self.update(id, **args)
      Mangadex::Internal::Definition.must(id)

      Mangadex::Internal::Request.put(
        '/chapter/%{id}' % {id: id},
        payload: Mangadex::Internal::Definition.validate(args, {
          title: { accepts: String },
          volume: { accepts: String },
          chapter: { accepts: String },
          translated_language: { accepts: %r{^[a-zA-Z\-]{2,5}$} },
          groups: { accepts: [String] },
          version: { accepts: Integer, required: true },
        }),
      )
    end

    sig { params(id: String).returns(Hash) }
    def self.delete(id)
      Mangadex::Internal::Definition.must(id)

      Mangadex::Internal::Request.delete(
        '/chapter/%{id}' % {id: id},
      )
    end

    class << self
      alias_method :view, :get
    end

    sig { returns(String) }
    def title
      attributes&.title.presence || chapter.presence && "Chapter #{chapter}" || "N/A"
    end

    sig { returns(T.nilable(String)) }
    def locale
      found_locale = translated_language.split('-').first
      return if found_locale.nil?

      ISO_639.find(found_locale)
    end

    sig { returns(T.nilable(String)) }
    def locale_name
      locale&.english_name
    end

    sig { returns(Integer) }
    def page_count
      Array(data).count
    end

    sig { returns(T.nilable(String)) }
    def preview_image_url
      return if data_saver.empty?

      "https://uploads.mangadex.org/data-saver/#{attributes.hash}/#{data_saver.first}"
    end

    def as_json(*)
      super.merge({
        locale_name: locale_name,
        preview_image_url: preview_image_url,
      })
    end

    def self.attributes_to_inspect
      [:id, :type, :title, :volume, :chapter, :page_count, :publish_at]
    end
  end
end
