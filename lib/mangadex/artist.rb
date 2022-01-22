# typed: true
require_relative "author"

module Mangadex
  class Artist < MangadexObject
    # Indicates if this is an artist
    #
    # @return [Boolean] whether this is an artist or not.
    has_attributes \
      :name,
      :image_url,
      :biography,
      :twitter,
      :pixiv,
      :melon_book,
      :fan_box,
      :booth,
      :nico_video,
      :skeb,
      :fantia,
      :tumblr,
      :youtube,
      :weibo,
      :naver,
      :website,
      :version,
      :created_at,
      :updated_at

    def artist?
      true
    end
  end
end
