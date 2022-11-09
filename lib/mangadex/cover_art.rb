# typed: false
require_relative "mangadex_object"

module Mangadex
  class CoverArt < MangadexObject
    has_attributes \
      :description,
      :volume,
      :file_name,
      :locale,
      :created_at,
      :updated_at,
      :version

    sig { params(args: T::Api::Arguments).returns(Mangadex::Api::Response[CoverArt]) }
    def self.list(**args)
      Mangadex::Internal::Request.get(
        '/cover',
        Mangadex::Internal::Definition.validate(args, {
          limit: { accepts: Integer, converts: :to_i },
          offset: { accepts: Integer, converts: :to_i },
          manga: { accepts: [String], converts: :to_a },
          ids: { accepts: [String], converts: :to_a },
          uploaders: { accepts: [String], converts: :to_a },
          order: { accepts: Hash },
          includes: { accepts: [String], converts: :to_a },
        })
      )
    end

    sig do
      params(
        file: String,
        volume: T.nilable(T.any(String, Integer)),
        manga_id: String,
      ).returns(Mangadex::Api::Response[CoverArt])
    end
    def self.upload(file, volume=nil, manga_id:)
      args = { file: file, volume: volume }
      Mangadex::Internal::Request.post(
        '/cover/%{manga_id}' % {manga_id: manga_id},
        payload: Mangadex::Internal::Definition.validate(args, {
          file: { accepts: String, required: true },
          volume: { accepts: %r{^(0|[1-9]\\d*)((\\.\\d+){1,2})?[a-z]?$} } # todo: double check regexp here
        })
      )
    end

    sig { params(id: String, args: T::Api::Arguments).returns(Mangadex::Api::Response[CoverArt]) }
    def self.get(id, **args)
      Mangadex::Internal::Definition.must(id)

      Mangadex::Internal::Request.get(
        '/cover/%{id}' % {id: id},
        Mangadex::Internal::Definition.validate(args, {
          includes: { accepts: [String], converts: :to_a },
        })
      )
    end

    sig { params(id: String, args: T::Api::Arguments).returns(Mangadex::Api::Response[CoverArt]) }
    def self.edit(id, **args)
      Mangadex::Internal::Definition.must(id)

      Mangadex::Internal::Request.put(
        '/cover/%{id}' % {id: id},
        Mangadex::Internal::Definition.validate(args, {
          volume: { accepts: String },
          description: { accepts: String },
          version: { accepts: Integer, required: true }
        })
      )
    end

    sig { params(id: String).returns(Hash) }
    def self.delete(id)
      Mangadex::Internal::Definition.must(id)

      Mangadex::Internal::Request.delete(
        '/cover/%{id}' % {id: id},
      )
    end

    class << self
      alias_method :view, :get
      alias_method :update, :edit
    end

    sig { params(size: T::Api::Text).returns(T.nilable(String)) }
    def image_url(size: :small)
      return unless manga.present?

      extension = case size.to_sym
      when :original
        ''
      when :medium
        '.512.jpg'
      else # :small by default
        '.256.jpg'
      end

      "https://uploads.mangadex.org/covers/#{manga.id}/#{file_name}#{extension}"
    end
  end
end
