# typed: ignore

module Interceptors
  class Mangadex < Base
    match(%{api\.mangadex\.org})

    get '/manga' do
      limit = params['limit'].nil? ? 10 : params['limit'].to_i
      Factories::Builder.list('manga', limit) do |index|
        {
          attributes: {
            title: { "en" => "Manga Title #{index}" },
            description: { "en" => "Manga Description #{index}" },
            content_rating: "safe",
          }
        }
      end
    end

    get '/manga/:id' do
      Factories::Builder.entity('manga', params['id']) do
        {
          title: {"en" => "My title"}
        }
      end
    end

    post '/auth/login' do
      {
        result: 'ok',
        token: {
          session: SecureRandom.uuid,
          refresh: SecureRandom.uuid,
        }
      }
    end
  end
end
