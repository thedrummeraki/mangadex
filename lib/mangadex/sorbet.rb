# typed: false

# These are custom alias Sorbet types

module T
  module Api
    Arguments = T.type_alias { T.any(String, T::Array[String], Integer, T::Hash[String, String]) }
    MangaResponse = T.type_alias do
      T.any(
        Mangadex::Api::Response[Mangadex::Manga],
        Mangadex::Api::Response[T::Array[Mangadex::Manga]]
      )
    end
    ChapterResponse = T.type_alias do
      T.any(
        Mangadex::Api::Response[Mangadex::Chapter],
        Mangadex::Api::Response[T::Array[Mangadex::Chapter]]
      )
    end
    GenericResponse = T.type_alias do
      T.any(
        ::Hash,
        Mangadex::Api::Response,
      )
    end
  end
end
