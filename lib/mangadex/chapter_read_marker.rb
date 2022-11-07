module Mangadex
  class ChapterReadMarker
    extend T::Sig

    sig { params(id: String).returns(T::Api::GenericResponse) }
    def self.get(id)
      Mangadex::Internal::Definition.must(id)

      Mangadex::Internal::Request.get(
        '/manga/{id}/read' % {id: id}
      )
    end

    sig { params(id: String, args: T::Api::Arguments).returns(T::Api::GenericResponse) }
    def self.create(id, **args)
      Mangadex::Internal::Definition.must(id)

      Mangadex::Internal::Request.post(
        '/manga/{id}/read' % {id: id},
        payload: Mangadex::Internal::Definition.validate(args, {
          update_history: { accepts: [true, false] }
        })
      )
    end

    sig { sig(args: T::Api::Arguments).returns(T::Api::GenericResponse) }
    def self.list(**args)
      Mangadex::Internal::Request.get(
        '/manga/list',
        Mangadex::Internal::Definition.validate(args, {
          ids: { accepts: [String], converts: :to_a, required: true },
          grouped: { accepts: [true, false] },
        })
      )
    end

    sig { returns(T::Api::GenericResponse) }
    def self.user_list
      Mangadex::Internal::Request.get(
        '/user/history',
        auth: true,
      )
    end
  end
end
