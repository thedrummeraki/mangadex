module Mangadex
  module Storage
    class Basic
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
    end
  end
end
