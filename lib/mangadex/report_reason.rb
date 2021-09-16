module Mangadex
  class ReportReason < MangadexObject
    has_attributes \
      :reason,
      :details_required,
      :category,
      :version

    class << self
      def list(category)
        args = Mangadex::Internal::Definition.validate({category: category}, {
          category: { accepts: %w(manga chapter scanlation_group user), required: true },
        })

        Mangadex::Internal::Request.get(
          '/report/reasons/%{category}' % args,
        )
      end

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

    def self.attributes_to_inspect
      self.attributes
    end
  end
end

