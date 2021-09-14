module Mangadex
  class Report < MangadexObject
    has_attributes \
      :reason,
      :details_required,
      :category,
      :version
  end
end

