module Mangadex
  module Storage
    class None
      def get(_scope, _key); end

      def set(_scope, _key, _value); end
    end
  end
end
