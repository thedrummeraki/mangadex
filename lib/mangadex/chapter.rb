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

    class << self
      def attributes_to_inspect
        [:id, :type, :title, :volume, :chapter, :page_count, :publish_at]
      end
    end

    def title
      attributes&.title.presence || chapter.presence && "Chapter #{chapter}" || "N/A"
    end

    def locale
      found_locale = translated_language.split('-').first
      return if found_locale.nil?

      ISO_639.find(found_locale)
    end

    def locale_name
      locale&.english_name
    end

    def page_count
      Array(data).count
    end

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
  end
end
