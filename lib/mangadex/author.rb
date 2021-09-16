require_relative "mangadex_object"

module Mangadex
  class Author < MangadexObject
    has_attributes :name, :image_url, :biography, :version, :created_at, :updated_at

    class << self
      def list(**args)
        Mangadex::Internal::Request.get(
          '/author',
          Mangadex::Internal::Definition.validate(args, {
            limit: { accepts: Integer },
            offset: { accepts: Integer },
            ids: { accepts: [String] },
            name: { accepts: String },
            order: { accepts: Hash },
            includes: { accepts: [String] },
          }),
        )
      end

      def create(**args)
        Mangadex::Internal::Request.post(
          '/author',
          payload: Mangadex::Internal::Definition.validate(args, {
            name: { accepts: String, required: true },
            version: { accepts: Integer },
          }),
        )
      end

      def get(id, **args)
        Mangadex::Internal::Request.get(
          '/author/%{id}' % {id: id},
          Mangadex::Internal::Definition.validate(args, {
            includes: { accepts: [String] },
          }),
        )
      end

      def update(id, **args)
        Mangadex::Internal::Request.put(
          '/author/%{id}' % {id: id},
          payload: Mangadex::Internal::Definition.validate(args, {
            name: { accepts: String },
            version: { accepts: Integer, required: true },
          }),
        )
      end

      def delete(id)
        Mangadex::Internal::Request.delete(
          '/author/%{id}' % {id: id},
        )
      end
    end

    def self.inspect_attributes
      [:name]
    end

    def artist?
      false
    end
  end
end