module Mangadex
  class Upload < MangadexObject
    has_attributes \
      :is_committed,
      :is_processed,
      :is_deleted,
      :version,
      :created_at,
      :updated_at

    def self.inspect_attributes
      [:is_committed, :is_processed, :is_deleted]
    end
  end
end

