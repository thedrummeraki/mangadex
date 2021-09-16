module Mangadex
  class ScanlationGroup < MangadexObject
    has_attributes \
      :name,
      :website,
      :irc_channel,
      :irc_server,
      :discord,
      :contact_email,
      :description,
      :locked,
      :official,
      :verified,
      :version,
      :created_at,
      :updated_at
  end

  def self.inspect_attributes
    self.attributes - [:version, :created_at, :updated_at]
  end
end
