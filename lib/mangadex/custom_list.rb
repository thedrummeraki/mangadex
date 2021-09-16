require_relative "mangadex_object"

module Mangadex
  class CustomList < MangadexObject
    has_attributes \
      :name,
      :visibility,
      :version

    class << self
      def create
      end

      def get(id)
        Mangadex::Internal::Request.get(
          '/list/%{id}' % {id: id},
        )
      end

      def update(id, **args)
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

      def delete(id)
        Mangadex::Internal::Request.delete(
          '/list/%{id}' % {id: id},
        )
      end

      def feed(id, **args)
        Mangadex::Internal::Request.get(
          '/list/%{id}/feed' % {id: id},
          Mangadex::Internal::Definition.chapter_list(args),
        )
      end

      def add_manga(id, list_id:)
        response = Mangadex::Internal::Request.post(
          '/manga/%{id}/list/%{list_id}' % {id: id, list_id: list_id},
        )
        if response.is_a?(Hash)
          response['result'] == 'ok'
        else
          !response.errored?
        end
      end

      def remove_manga(id, list_id:)
        response = Mangadex::Internal::Request.delete(
          '/manga/%{id}/list/%{list_id}' % {id: id, list_id: list_id},
        )
        if response.is_a?(Hash)
          response['result'] == 'ok'
        else
          !response.errored?
        end
      end

      def list(**args)
        Mangadex::Internal::Request.get(
          '/user/list',
          Mangadex::Internal::Definition.validate(args, {
            limit: { accepts: Integer },
            offset: { accepts: Integer },
          }),
        )
      end

      def user_list(user_id, **args)
        Mangadex::Internal::Request.get(
          '/user/%{id}/list' % {id: user_id},
          Mangadex::Internal::Definition.validate(args, {
            limit: { accepts: Integer },
            offset: { accepts: Integer },
          }),
        )
      end
    end

    def add_manga(id)
      Mangadex::CustomList.add_manga(id, list_id: self.id)
    end

    def remove_manga(id)
      Mangadex::CustomList.remove_manga(id, list_id: self.id)
    end

    def manga_details(**args)
      ids = mangas.map(&:id)
      ids.any? ? Mangadex::Manga.list(**args.merge(ids: ids)) : []
    end

    def self.inspect_attributes
      [:name, :visibility]
    end
  end
end

