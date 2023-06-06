# typed: false
module Mangadex
  class ScanlationGroup < MangadexObject
    has_attributes \
      :name,
      :alt_names,
      :website,
      :irc_channel,
      :irc_server,
      :discord,
      :contact_email,
      :description,
      :twitter,
      :locked,
      :official,
      :verified,
      :focused_languages,
      :publish_delay,
      :inactive,
      :ex_licensed,
      :manga_updates,
      :version,
      :created_at,
      :updated_at

    class << self
      def list(**args)
        Mangadex::Internal::Request.get(
          '/group',
          Mangadex::Internal::Definition.validate(args, {
            limit: { accepts: Integer, converts: :to_i },
            offset: { accepts: Integer, converts: :to_i },
            ids: { accepts: [String], converts: :to_a },
            name: { accepts: String },
            includes: { accepts: [String], converts: :to_a },
          }),
        )
      end

      def create(**args)
        Mangadex::Internal::Request.post(
          '/group',
          payload: Mangadex::Internal::Definition.validate(args, {
            name: { accepts: String, required: true },
            website: { accepts: String },
            irc_server: { accepts: String },
            irc_channel: { accepts: String },
            discord: { accepts: String },
            contact_email: { accepts: String },
            description: { accepts: String },
          }),
        )
      end

      def view(id)
        Mangadex::Internal::Definition.must(id)

        Mangadex::Internal::Request.get(
          '/group/%{id}' % {id: id},
          Mangadex::Internal::Definition.validate(args, {
            includes: { accepts: [String], converts: :to_a },
          }),
        )
      end

      def update(id, **args)
        Mangadex::Internal::Request.put(
          '/group/%{id}' % {id: id},
          payload: Mangadex::Internal::Definition.validate(args, {
            name: { accepts: String },
            website: { accepts: String },
            irc_server: { accepts: String },
            irc_channel: { accepts: String },
            discord: { accepts: String },
            contact_email: { accepts: String },
            description: { accepts: String },
            locked: { accepts: [true, false] },
            version: { accepts: Integer, required: true },
          }),
        )
      end

      def delete(id)
        Mangadex::Internal::Request.delete(
          '/group/%{id}' % {id: id},
        )
      end

      def follow(id)
        Mangadex::Internal::Request.post(
          '/group/%{id}/follow' % {id: id},
        )
      end

      def unfollow(id)
        Mangadex::Internal::Request.delete(
          '/group/%{id}/follow' % {id: id},
        )
      end
    end

    class << self
      alias_method :get, :view
      alias_method :edit, :update
    end

    def self.inspect_attributes
      self.attributes - [:version, :created_at, :updated_at]
    end
  end
end
