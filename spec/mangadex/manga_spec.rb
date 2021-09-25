# typed: ignore

RSpec.describe Mangadex::Manga do
  it "lists all manga" do
    Interceptors::Mangadex.intercept do
      response = Mangadex::Manga.list

      expect(response).to be_a(Mangadex::Api::Response)
      expect(response).not_to be_errored
    end
  end

  it "fetches one manga by id" do
    Interceptors::Mangadex.intercept do
      id = SecureRandom.uuid
      response = Mangadex::Manga.view(id)

      expect(response).to be_a(Mangadex::Api::Response)
      expect(response.data.id).to eq(id)
    end
  end

  it "fails" do
    interceptor = Interceptors::Mangadex.customize do
      get '/manga' do
        Factories::Builder.error(500) do |index|
          { 
            id: "error-#{index}",
            status: "unknown error #{index + 1}"
          }
        end
      end
    end

    interceptor.intercept do
      response = Mangadex::Manga.list
    end
  end
end

