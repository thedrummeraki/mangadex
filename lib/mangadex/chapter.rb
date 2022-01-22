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
      :pages,
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
        content_rating: true,
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

    sig { params(data_saver: T::Boolean).returns(T.nilable(T::Array[String])) }
    def page_urls(data_saver: true)
      Mangadex::AtHome.page_urls(id, data_saver: data_saver)
    end

    def as_json(*)
      super.merge({
        preview_image_url: preview_image_url,
      })
    end

    def self.attributes_to_inspect
      [:id, :type, :title, :volume, :chapter, :pages, :publish_at]
    end
  end
end
