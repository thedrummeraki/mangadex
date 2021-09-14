module Mangadex
  class ScanlationGroup < MangadexObject
    has_attributes \
      :name,
      :website,
      :irc_server,
      :discord,
      :contact_email,
      :description,
      :locked,
      :official,
      :version,
      :created_at,
      :updated_at
  end
end
