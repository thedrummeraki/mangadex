module Mangadex
  class Report < MangadexObject
    has_attributes \
      :details,
      :object_id,
      :status,
      :created_at

    sig { params(args: T::Api::Arguments).returns(Mangadex::Api::Response[Report]) }
    def self.list(**args)
      Mangadex::Internal::Request.get(
        '/report',
        Mangadex::Internal::Definition.validate(args, {
          limit: { accepts: Integer, converts: :to_i },
          offset: { accepts: Integer, converts: :to_i },
          category: { accepts: %w(manga chapter scanlation_group user author) },
          reason_id: { accepts: String },
          object_id: { accepts: String },
          status: { accepts: %w(waiting accepted refused autoresolved) },
          order: { accepts: Hash },
          includes: { accepts: Array, converts: :to_a },
        }),
        auth: true,
      )
    end

    sig { params(args: T::Api::Arguments).returns(T::Api::GenericResponse) }
    def create(**args)
      Mangadex::Internal::Request.post(
        '/report',
        payload: Mangadex::Internal::Definition.validate(args, {
          category: { accepts: %w(manga chapter scanlation_group user), required: true },
          reason: { accepts: String, required: true },
          object_id: { accepts: String, required: true },
          details: { accepts: String },
        }),
      )
    end
  end
end
