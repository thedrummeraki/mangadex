module Mangadex
  module Storage
    class Basic
      def initialize(scope = nil)
        @scope = scope
      end

      def get(_scope, _key)
        raise NotImplementedError
      end

      def set(_scope, _key, _value)
        raise NotImplementedError
      end

      def clear(_scope)
        warn("Don't know how to clear #{self.class} storage strategy! Skipping...")
        nil
      end

      protected

      def parent_scope_for(scope)
        return scope if @scope.nil?

        "#{@scope}.#{scope}"        
      end
    end
  end
end
