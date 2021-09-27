# typed: false
module Mangadex
  class User < MangadexObject
    has_attributes \
      :username,
      :roles,
      :version

    sig { params(args: T::Api::Arguments).returns(Mangadex::Api::Response[Mangadex::Chapter]) }
    def self.feed(**args)
      Mangadex::Internal::Request.get(
        '/user/follows/manga/feed',
        Mangadex::Internal::Definition.chapter_list(args),
        auth: true,
      )
    end

    sig { params(args: T::Api::Arguments).returns(Mangadex::Api::Response[Mangadex::ScanlationGroup]) }
    def self.followed_groups(**args)
      Mangadex::Internal::Request.get(
        '/user/follows/group',
        Mangadex::Internal::Definition.validate(args, {
          limit: { accepts: Integer },
          offset: { accepts: Integer },
          includes: { accepts: Array },
        }),
        auth: true,
      )
    end

    sig { params(id: String).returns(T::Boolean) }
    def self.follows_group(id)
      Mangadex::Internal::Definition.must(id)

      data = Mangadex::Internal::Request.get(
        '/user/follows/group/%{id}' % {id: id},
        raw: true,
        auth: true,
      )
      JSON.parse(data)['result'] == 'ok'
    rescue JSON::ParserError => error
      warn(error)
      false
    end

    sig { params(args: T::Api::Arguments).returns(Mangadex::Api::Response[Mangadex::User]) }
    def self.followed_users(**args)
      Mangadex::Internal::Request.get(
        '/user/follows/user',
        Mangadex::Internal::Definition.validate(args, {
          limit: { accepts: Integer },
          offset: { accepts: Integer },
        }),
        auth: true,
      )
    end

    sig { params(id: String).returns(T::Boolean) }
    def self.follows_user(id)
      Mangadex::Internal::Definition.must(id)

      return if Mangadex::Api::Context.user.nil?

      data = Mangadex::Internal::Request.get(
        '/user/follows/user/%{id}' % {id: id},
        raw: true,
        auth: true,
      )
      JSON.parse(data)['result'] == 'ok'
    rescue JSON::ParserError => error
      warn(error)
      false
    end

    sig { params(args: T::Api::Arguments).returns(Mangadex::Api::Response[Mangadex::Manga]) }
    def self.followed_manga(**args)
      Mangadex::Internal::Request.get(
        '/user/follows/manga',
        Mangadex::Internal::Definition.validate(args, {
          limit: { accepts: Integer },
          offset: { accepts: Integer },
          includes: { accepts: Array },
        }),
        auth: true,
      )
    end

    sig { params(id: String).returns(T::Boolean) }
    def self.follows_manga(id)
      Mangadex::Internal::Definition.must(id)

      return if Mangadex::Api::Context.user.nil?

      data = Mangadex::Internal::Request.get(
        '/user/follows/manga/%{id}' % {id: id},
        raw: true,
        auth: true,
      )
      JSON.parse(data)['result'] == 'ok'
    rescue JSON::ParserError => error
      warn(error)
      false
    end

    def self.attributes_to_inspect
      [:username, :roles]
    end
  end
end
