module Mangadex
  class Thread < MangadexObject
    has_attributes \
      :replies_count

    class << self
      def create(type:, id:)
        payload = {type: type, id: id}
        Mangadex::Internal::Request.post(
          '/forums/thread',
          payload: Mangadex::Internal::Definition.validate(payload, {
            type: { accepts: %w(manga group chapter), converts: :to_s, required: true },
            id: { accepts: String, required: true },
          }),
          auth: true,
        )
      end
    end

    def self.attributes_to_inspect
      [:id, :type, :replies_count]
    end
  end
end
