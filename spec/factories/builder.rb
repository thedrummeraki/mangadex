module Factories
  # Usage:
  # This was designed to be used the request interceptors, but
  # all methods that return "records" can be used anywhered in the
  # tests.
  # 
  # # Gets a list of 20 records of type "manga".
  # Factories::Builder.list('manga', 20) do |index|
  #   {
  #     attributes: {
  #       title: { "en" => "Manga Title #{index}" },
  #       description: { "en" => "Manga Description #{index}" },
  #       content_rating: "safe",
  #     }
  #   }
  # end
  #
  # # Gets a record of type "manga" with ID "manga-id".
  # Factories::Builder.entity('manga', 'manga-id') do |index|
  #   {
  #     title: {"en" => "My title"}
  #   }
  # end
  #
  # # Return a list of 5 Mangadex errors, that ended with HTTP status 418
  # Factories::Builder.error(418, 5) do |index|
  #   {
  #     id: "error-#{index}",
  #     status: "my error",
  #   }
  # end

  class Builder
    def self.list(record_type, count=10, result: 'ok', offset: 0, total: 10, &block)
      {
        result: result,
        response: 'collection',
        limit: count,
        offset: offset,
        total: total,
        data: (
          Mangadex::Api::Response::Collection.new(
            count.times.map do |index|
              yield(index).merge({
                type: record_type,
              })
            end
          )
        )
      }
    end

    def self.entity(record_type, id, result: 'ok', &attributes)
      {
        result: result,
        response: 'entity',
        data: {
          id: id,
          type: record_type,
          attributes: yield
        }
      }
    end

    def self.error(status=500, count=1, &block)
      body = {
        result: 'ko',
        response: 'error',
        errors: (
          count.times.map do |index|
            yield(index)
          end
        )
      }
      [status, body]
    end
  end
end
