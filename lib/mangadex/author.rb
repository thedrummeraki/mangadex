# typed: true

require_relative 'mangadex_object'

module Mangadex
  class Author < MangadexObject
    has_attributes \
      :name,
      :image_url,
      :biography,
      :twitter,
      :pixiv,
      :melon_book,
      :fan_box,
      :booth,
      :nico_video,
      :skeb,
      :fantia,
      :tumblr,
      :youtube,
      :weibo,
      :naver,
      :website,
      :version,
      :created_at,
      :updated_at

    # List all authors.
    # Path: +GET /author+
    # Reference: https://api.mangadex.org/docs.html#operation/get-author
    #
    # @return [Mangadex::Api::Response] with a collection of authors
    sig { params(args: T::Api::Arguments).returns(Mangadex::Api::Response[Author]) }
    def self.list(**args)
      Mangadex::Internal::Request.get(
        '/author',
        Mangadex::Internal::Definition.validate(args, {
          limit: { accepts: Integer, converts: :to_i },
          offset: { accepts: Integer, converts: :to_i },
          ids: { accepts: [String] },
          name: { accepts: String },
          order: { accepts: Hash },
          includes: { accepts: [String] },
        })
      )
    end

    # Create an author.
    # Path: +POST /author+
    # Reference: https://api.mangadex.org/docs.html#operation/post-author
    #
    # @return [Mangadex::Api::Response] with newly created author
    sig { params(args: T::Api::Arguments).returns(Mangadex::Api::Response[Author]) }
    def self.create(**args)
      Mangadex::Internal::Request.post(
        '/author',
        payload: Mangadex::Internal::Definition.validate(args, {
          name: { accepts: String, required: true },
          version: { accepts: Integer },
        })
      )
    end

    # Get an author by ID.
    # Path: +GET /author/:id+
    # Reference: https://api.mangadex.org/docs.html#operation/get-author-id
    #
    # @return [Mangadex::Api::Response] with a entity of author
    sig { params(id: String, args: T::Api::Arguments).returns(Mangadex::Api::Response[Author]) }
    def self.get(id, **args)
      Mangadex::Internal::Definition.must(id)

      Mangadex::Internal::Request.get(
        format('/author/%{id}', id: id),
        Mangadex::Internal::Definition.validate(args, {
          includes: { accepts: [String] },
        })
      )
    end

    # Update an author.
    # Path: +POST /author/:id+
    # Reference: https://api.mangadex.org/docs.html#operation/put-author-id
    #
    # @return [Mangadex::Api::Response] with a entity of author
    sig { params(id: String, args: T::Api::Arguments).returns(Mangadex::Api::Response[Author]) }
    def self.update(id, **args)
      Mangadex::Internal::Definition.must(id)

      Mangadex::Internal::Request.put(
        format('/author/%{id}', id: id),
        payload: Mangadex::Internal::Definition.validate(args, {
          name: { accepts: String },
          version: { accepts: Integer, required: true },
        })
      )
    end

    # Delete an author.
    # Path: +DELETE /author/:id+
    # Reference: https://api.mangadex.org/docs.html#operation/delete-author-id
    #
    # @param id Author's ID
    # @return [Hash]
    sig { params(id: String).returns(Hash) }
    def self.delete(id)
      Mangadex::Internal::Definition.must(id)

      Mangadex::Internal::Request.delete(
        format('/author/%{id}', id: id)
      )
    end

    def self.inspect_attributes
      [:name]
    end

    class << self
      alias_method :view, :get
    end

    # Indicates if this is an artist
    #
    # @return [Boolean] whether this is an artist or not.
    sig { returns(T::Boolean) }
    def artist?
      false
    end
  end
end
