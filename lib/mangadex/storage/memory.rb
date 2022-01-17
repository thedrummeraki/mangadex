module Mangadex
  module Storage
    class Memory < Basic
      def initialize(scope = nil)
        @storage = {}
        @scope = scope
      end

      def get(scope, key)
        @storage.dig(parent_scope_for(scope), key.to_s)
      end

      def set(scope, key, value)
        scope = parent_scope_for(scope)
        key = key.to_s

        @storage[scope] = {} unless @storage.has_key?(scope)
        @storage[scope][key] = value
      end

      def clear(scope)
        @storage.delete(parent_scope_for(scope))
      end
    end
  end
end
