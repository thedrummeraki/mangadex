# typed: ignore

RSpec.describe Mangadex::Api::Context do
  it 'sets the user from Mangadex::Api::User' do
    api_user = Mangadex::Api::User.new(
      'dummy-id'
    )
    expect do
      Mangadex::Api::Context.user = api_user
    end.not_to raise_error
    expect(Mangadex::Api::Context.user).to eq(api_user)
  end

  it 'sets the user from Mangadex::User' do
    mangadex_user = Mangadex::User.from_data({
      id: 'dummy-id',
      attributes: {
        name: 'thedrummeraki',
      }
    })
    expect do
      Mangadex::Api::Context.user = mangadex_user
    end.not_to raise_error
    expect(Mangadex::Api::Context.user.mangadex_user_id).to eq('dummy-id')
    expect(Mangadex::Api::Context.user.data).to eq(mangadex_user)
  end

  it 'sets the user from Hash' do
    expect do
      Mangadex::Api::Context.user = {
        mangadex_user_id: 'dummy-id',
        session: 'session',
        refresh: 'refresh',
      }
    end.not_to raise_error
    expect(Mangadex::Api::Context.user.mangadex_user_id).to eq('dummy-id')
    expect(Mangadex::Api::Context.user.session).to eq('session')
    expect(Mangadex::Api::Context.user.refresh).to eq('refresh')
  end

  it 'fails to set a user from invalid Hash' do
    expect do
      Mangadex::Api::Context.user = {
        blah: 'blah',
      }
    end.to raise_error(ArgumentError)
  end

  it 'fails to set a user from the wrong type' do
    expect do
      Mangadex::Api::Context.user = 1
    end.to raise_error(TypeError)
  end

  it 'sets a temp user' do
    user_1 = Mangadex::Api::User.new(
      'one'
    )
    user_2 = Mangadex::Api::User.new(
      'two'
    )
    Mangadex::Api::Context.user = user_1
    expect(Mangadex::Api::Context.user.mangadex_user_id).to eq('one')

    Mangadex::Api::Context.with_user(user_2) do
      expect(Mangadex::Api::Context.user.mangadex_user_id).to eq('two')
    end

    expect(Mangadex::Api::Context.user.mangadex_user_id).to eq('one')
  end

  it 'sets temp allowed content ratings' do
    original_content_ratings = Mangadex::Api::Context.allow_content_ratings('safe', 'suggestive', 'erotica')

    Mangadex::Api::Context.allow_content_ratings('safe') do
      expect(Mangadex::Api::Context.allowed_content_ratings).to eq(['safe'])
    end

    expect(Mangadex::Api::Context.allowed_content_ratings).to eq(original_content_ratings)
  end

  it 'uses content ratings when calling API' do
    Mangadex::Api::Context.allow_content_ratings('pornographic', 'safe')
    interceptor = Interceptors::Mangadex.customize do
      get '/manga' do
        Factories::Builder.list('manga').merge({params: params})
      end
    end

    interceptor.intercept do
      response = Mangadex::Manga.list
      expect(response.raw_data.dig("params", "contentRating")).to eq(['pornographic', 'safe'])
    end
  end
end
