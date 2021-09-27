# typed: true
module Mangadex
  class Tag < MangadexObject
    has_attributes :name, :description, :group, :version

    sig { returns(Mangadex::Api::Response[Mangadex::Tag]) }
    def self.list
      Mangadex::Manga.tag_list
    end

    def self.attributes_to_inspect
      %i(name)
    end
  end
end
