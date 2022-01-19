# typed: true

module Mangadex
  class AtHome
    extend T::Sig

    sig { params(chapter_id: String).returns(T.any(Mangadex::Api::Response, Hash)) }
    def self.server(chapter_id)
      Mangadex::Internal::Request.get(
        "/at-home/server/#{chapter_id}",
      )
    end

    sig { params(chapter_id: String, data_saver: T::Boolean).returns(T.nilable(T::Array[String])) }
    def self.page_urls(chapter_id, data_saver: true)
      response = self.server(chapter_id)
      return if response.is_a?(Mangadex::Api::Response)

      base_url = response['baseUrl']
      chapter_data = response['chapter']
      hash = chapter_data['hash']
      source = data_saver ? chapter_data['dataSaver'] : chapter_data['data']
      data_source = data_saver ? 'data-saver' : 'data'

      source.map do |filename|
        [base_url, data_source, hash, filename].join('/')
      end
    end
  end
end
