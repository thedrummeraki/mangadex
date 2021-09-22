# typed: false
module Mangadex
  class Upload < MangadexObject
    has_attributes \
      :is_committed,
      :is_processed,
      :is_deleted,
      :version,
      :created_at,
      :updated_at

    class << self
      def current
        Mangadex::Internal::Request.get(
          '/upload',
        )
      end

      def start(**args)
        Mangadex::Internal::Request.post(
          '/upload/begin',
          payload: Mangadex::Internal::Definition.validate(args, {
            groups: { accepts: [String], required: true },
            manga: { accepts: String, required: true },
          }),
        )
      end
      alias_method :begin, :start

      def upload_images(upload_session_id)
        Mangadex::Internal::Request.post(
          '/upload/%{upload_session_id}' % {upload_session_id: upload_session_id},
          payload: Mangadex::Internal::Definition.validate(args, {
            file: { accepts: String },
          }),
        )
      end

      def abandon(upload_session_id)
        Mangadex::Internal::Request.delete(
          '/upload/%{upload_session_id}' % {upload_session_id: upload_session_id},
        )
      end
      alias_method :stop, :abandon

      def commit(upload_session_id, **args)
        Mangadex::Internal::Request.post(
          '/upload/%{upload_session_id}/commit' % {upload_session_id: upload_session_id},
          payload: Mangadex::Internal::Definition.validate(args, {
            chapter_draft: { accepts: Hash }, # todo enforce chapter_draft content?
            page_order: { accepts: [String] },
          }),
        )
      end

      def delete_uploaded_image(upload_session_id, upload_session_file_id)
        Mangadex::Internal::Request.delete(
          '/upload/%{upload_session_id}/%{upload_session_file_id}' % {
            upload_session_id: upload_session_id,
            upload_session_file_id: upload_session_file_id,
          },
        )
      end

      def delete_uploaded_images(upload_session_id, upload_session_file_ids)
        Mangadex::Internal::Request.delete(
          '/upload/%{upload_session_id}' % {upload_session_id: upload_session_id},
          payload: Array(upload_session_file_id),
        )
      end
    end

    def self.inspect_attributes
      [:is_committed, :is_processed, :is_deleted]
    end
  end
end

