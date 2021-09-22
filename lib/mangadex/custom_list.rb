# typed: false
require_relative "mangadex_object"

module Mangadex
  class CustomList < MangadexObject
    has_attributes \
      :name,
      :visibility,
      :version

    def self.create
    end

    sig { params(id: String).returns(Mangadex::Api::Response[CustomList]) }
    def self.get(id)
      Mangadex::Internal::Request.get(
        '/list/%{id}' % {id: id},
      )
    end

    sig { params(id: String, args: T::Api::Arguments).returns(Mangadex::Api::Response[CustomList]) }
    def self.update(id, **args)
      Mangadex::Internal::Request.put(
        '/list/%{id}' % {id: id},
        payload: Mangadex::Internal::Definition.validate(args, {
          name: { accepts: String },
          visibility: { accepts: %w(private public) },
          manga: { accepts: String },
          version: { accepts: Integer, required: true },
        })
      )
    end

    sig { params(id: String).returns(T::Boolean) }
    def self.delete(id)
      Mangadex::Internal::Request.delete(
        '/list/%{id}' % {id: id},
      )
    end

    sig { params(id: String, args: T::Api::Arguments).returns(Mangadex::Api::Response[Chapter]) }
    def self.feed(id, **args)
      Mangadex::Internal::Request.get(
        '/list/%{id}/feed' % {id: id},
        Mangadex::Internal::Definition.chapter_list(args),
      )
    end

    sig { params(id: String, list_id: String).returns(T::Boolean) }
    def self.add_manga(id, list_id:)
      response = Mangadex::Internal::Request.post(
        '/manga/%{id}/list/%{list_id}' % {id: id, list_id: list_id},
      )
      if response.is_a?(Hash)
        response['result'] == 'ok'
      else
        !response.errored?
      end
    end

    sig { params(id: String, list_id: String).returns(T::Boolean) }
    def self.remove_manga(id, list_id:)
      response = Mangadex::Internal::Request.delete(
        '/manga/%{id}/list/%{list_id}' % {id: id, list_id: list_id},
      )
      if response.is_a?(Hash)
        response['result'] == 'ok'
      else
        !response.errored?
      end
    end

    sig { params(args: T::Api::Arguments).returns(Mangadex::Api::Response[CustomList]) }
    def self.list(**args)
      Mangadex::Internal::Request.get(
        '/user/list',
        Mangadex::Internal::Definition.validate(args, {
          limit: { accepts: Integer },
          offset: { accepts: Integer },
        }),
      )
    end

    sig { params(user_id: String, args: T::Api::Arguments).returns(Mangadex::Api::Response[CustomList]) }
    def self.user_list(user_id, **args)
      Mangadex::Internal::Request.get(
        '/user/%{id}/list' % {id: user_id},
        Mangadex::Internal::Definition.validate(args, {
          limit: { accepts: Integer },
          offset: { accepts: Integer },
        }),
      )
    end

    sig { params(id: String).returns(T::Boolean) }
    def add_manga(id)
      Mangadex::CustomList.add_manga(id, list_id: self.id)
    end

    sig { params(id: String).returns(T::Boolean) }
    def remove_manga(id)
      Mangadex::CustomList.remove_manga(id, list_id: self.id)
    end

    sig { params(args: T::Api::Arguments).returns(Mangadex::Api::Response[Manga]) }
    def manga_details(**args)
      ids = mangas.map(&:id)
      ids.any? ? Mangadex::Manga.list(**args.merge(ids: ids)) : []
    end

    def self.inspect_attributes
      [:name, :visibility]
    end
  end
end

