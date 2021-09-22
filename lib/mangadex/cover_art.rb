# typed: false
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

    class << self
      def list(**args)
        Mangadex::Internal::Request.get(
          '/cover',
          Mangadex::Internal::Definition.validate(args, {
            limit: { accepts: Integer },
            offset: { accepts: Integer },
            manga: { accepts: [String] },
            ids: { accepts: [String] },
            uploaders: { accepts: [String] },
            order: { accepts: Hash },
            includes: { accepts: [String] },
          })
        )
      end

      def upload(file, volume=nil, manga_id:)
        args = { file: file, volume: volume }
        Mangadex::Internal::Request.post(
          '/cover/%{manga_id}' % {manga_id: manga_id},
          payload: Mangadex::Internal::Definition.validate(args, {
            file: { accepts: String, required: true },
            volume: { accepts: %r{^(0|[1-9]\\d*)((\\.\\d+){1,2})?[a-z]?$} } # todo: double check regexp here
          })
        )
      end

      def get(id, **args)
        Mangadex::Internal::Request.get(
          '/cover/%{id}' % {id: id},
          Mangadex::Internal::Definition.validate(args, {
            includes: { accepts: [String] },
          })
        )
      end

      def edit(id, **args)
        Mangadex::Internal::Request.put(
          '/cover/%{id}' % {id: id},
          Mangadex::Internal::Definition.validate(args, {
            volume: { accepts: String },
            description: { accepts: String },
            version: { accepts: Integer, required: true }
          })
        )
      end

      def delete(id)
        Mangadex::Internal::Request.delete(
          '/cover/%{id}' % {id: id},
        )
      end
    end

    def image_url(size: :small)
      return unless manga.present?
      
      extension = case size
      when :original
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
