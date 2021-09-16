require_relative "mangadex_object"

module Mangadex
  class Author < MangadexObject
    has_attributes :name, :image_url, :biography, :version, :created_at, :updated_at

    class << self
      def list(**args)
      end

      def create(**args)
      end

      def get(id, **args)
      end

      def update(id, **args)
      end

      def delete(id)
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