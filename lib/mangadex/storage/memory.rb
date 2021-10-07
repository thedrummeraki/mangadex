module Mangadex
  module Storage
    class Memory < BasicObject
      def initialize
        @storage = {}
      end

      def get(scope, key)
        @storage.dig(scope.to_s, key.to_s)
      end

      def set(scope, key, value)
        key = key.to_s
        @storage[scope] = {} unless @storage.has_key?(scope)
        @storage[scope][key] = value
      end

      def clear(scope)
        @storage.delete(scope)
      end
    end
  end
end
