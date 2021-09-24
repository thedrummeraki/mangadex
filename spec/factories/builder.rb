module Factories
  class Builder
    class MockResponse < Mangadex::Api::Response; end
    
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
