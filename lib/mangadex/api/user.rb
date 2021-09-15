module Mangadex
  module Api
    class User
      attr_accessor :mangadex_user_id, :session, :refresh

      def initialize(mangadex_user_id, session: nil, refresh: nil)
        raise ArgumentError, 'Missing mangadex_user_id' if mangadex_user_id.to_s.empty?

        @mangadex_user_id = mangadex_user_id
        @session = session
        @refresh = refresh
      end

      def refresh!
      end
    end
  end
end
