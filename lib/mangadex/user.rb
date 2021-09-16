module Mangadex
  class User < MangadexObject
    has_attributes \
      :username,
      :roles,
      :version

    class << self
      def feed(**args)
        Mangadex::Internal::Request.get(
          '/user/follows/manga/feed',
          Mangadex::Internal::Definition.chapter_list(args),
        )
      end

      def followed_groups(**args)
        Mangadex::Internal::Request.get(
          '/user/follows/group',
          Mangadex::Internal::Definition.validate(args, {
            limit: { accepts: Integer },
            offset: { accepts: Integer },
            includes: { accepts: Array },
          }),
        )
      end

      def follows_group(id)
        return if Mangadex::Api::Context.user.nil?

        data = Mangadex::Internal::Request.get(
          '/user/follows/group/%{id}' % {id: id},
          raw: true,
        )
        JSON.parse(data)['result'] == 'ok'
      rescue JSON::ParserError => error
        warn(error)
        false
      end

      def followed_users(**args)
        Mangadex::Internal::Request.get(
          '/user/follows/user',
          Mangadex::Internal::Definition.validate(args, {
            limit: { accepts: Integer },
            offset: { accepts: Integer },
          }),
        )
      end

      def follows_user(id)
        return if Mangadex::Api::Context.user.nil?

        data = Mangadex::Internal::Request.get(
          '/user/follows/user/%{id}' % {id: id},
          raw: true,
        )
        JSON.parse(data)['result'] == 'ok'
      rescue JSON::ParserError => error
        warn(error)
        false
      end

      def followed_manga(**args)
        Mangadex::Internal::Request.get(
          '/user/follows/manga',
          Mangadex::Internal::Definition.validate(args, {
            limit: { accepts: Integer },
            offset: { accepts: Integer },
            includes: { accepts: Array },
          }),
        )
      end

      def follows_manga(id, **args)
        return if Mangadex::Api::Context.user.nil?

        data = Mangadex::Internal::Request.get(
          '/user/follows/manga/%{id}' % {id: id},
          raw: true,
        )
        JSON.parse(data)['result'] == 'ok'
      rescue JSON::ParserError => error
        warn(error)
        false
      end
    end

    def self.attributes_to_inspect
      [:username, :roles]
    end
  end
end
