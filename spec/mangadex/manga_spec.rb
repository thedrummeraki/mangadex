# typed: ignore

RSpec.describe Mangadex::Manga do
  describe '#view' do
    it 'builds manga by id' do
      VCR.use_cassette("manga.id") do
        id = 'd86cf65b-5f6c-437d-a0af-19a31f94ec55'
        manga = Mangadex::Manga.view(id)
        expect(manga.id).to eq(id)
      end
    end
  end
end
