# typed: false

# These are custom alias Sorbet types

module T
  module Api
    Text = T.type_alias { T.any(String, Symbol) }

    Arguments = T.type_alias do
      T.any(
        Text,
        T::Array[Text],
        Integer,
        T::Hash[Text, Text],
      )
    end
    MangaResponse = T.type_alias do
      T.any(
        Mangadex::Api::Response[Mangadex::Manga],
        Mangadex::Api::Response[T::Array[Mangadex::Manga]],
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
    ContentRating = T.type_alias do
      T.any(
        String,
        ::Mangadex::ContentRating,
      )
    end
  end
end
