# typed: false
module Mangadex
  class User < MangadexObject
    has_attributes \
      :username,
      :roles,
      :version

    sig { params(args: T::Api::Arguments).returns(T::Api::UserResponse) }
    def self.list(**args)
      Mangadex::Internal::Request.get(
        '/user',
        Mangadex::Internal::Definition.validate(args, {
          limit: { accepts: Integer, converts: :to_i },
          offset: { accepts: Integer, converts: :to_i },
          ids: { accepts: Array },
          username: { accepts: String },
          order: { accepts: Hash },
        }),
        auth: true,
      )
    end

    sig { params(id: String).returns(T::Api::UserResponse) }
    def self.get(id)
      Mangadex::Internal::Request.get(
        "/user/#{id}",
      )
    end

    sig { params(id: String).returns(T::Api::GenericResponse) }
    def self.delete(id)
      Mangadex::Internal::Request.delete(
        "/user/#{id}",
        auth: true,
      )
    end

    sig { params(code: String).returns(T::Api::GenericResponse) }
    def self.delete_code(code)
      Mangadex::Internal::Request.post(
        "/user/delete/#{code}",
      )
    end

    sig { params(old_password: String, new_password: String).returns(T::Api::GenericResponse) }
    def self.update_password(old_password:, new_password:)
      payload = {
        oldPassword: old_password,
        newPassword: new_password,
      }

      Mangadex::Internal::Request.post(
        '/user/password',
        payload: payload,
        auth: true,
      )
    end

    sig { params(email: String).returns(T::Api::GenericResponse) }
    def self.update_email(email:)
      Mangadex::Internal::Request.post(
        '/user/email',
        payload: { email: email },
        auth: true,
      )
    end

    sig { returns(T::Api::UserResponse) }
    def self.current
      Mangadex::Internal::Request.get(
        '/user/me',
        auth: true,
      )
    end

    sig { params(args: T::Api::Arguments).returns(Mangadex::Api::Response[Mangadex::Chapter]) }
    def self.feed(**args)
      Mangadex::Internal::Request.get(
        '/user/follows/manga/feed',
        Mangadex::Internal::Definition.chapter_list(args),
        content_rating: true,
        auth: true,
      )
    end

    sig { params(args: T::Api::Arguments).returns(Mangadex::Api::Response[Mangadex::ScanlationGroup]) }
    def self.followed_groups(**args)
      Mangadex::Internal::Request.get(
        '/user/follows/group',
        Mangadex::Internal::Definition.validate(args, {
          limit: { accepts: Integer, converts: :to_i },
          offset: { accepts: Integer, converts: :to_i },
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
          limit: { accepts: Integer, converts: :to_i },
          offset: { accepts: Integer, converts: :to_i },
        }),
        auth: true,
      )
    end

    sig { params(id: String).returns(T::Boolean) }
    def self.follows_user(id)
      Mangadex::Internal::Definition.must(id)

      return if Mangadex.context.user.nil?

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

      return if Mangadex.context.user.nil?

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
