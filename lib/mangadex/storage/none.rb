module Mangadex
  module Storage
    class None < Basic
      def get(_scope, _key); end
      def set(_scope, _key, _value); end
      def clear(_scope); end
    end
  end
end
