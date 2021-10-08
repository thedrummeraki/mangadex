# typed: ignore

RSpec.describe Mangadex::Internal::Context do
  it 'sets the user from Mangadex::Api::User' do
    api_user = Mangadex::Api::User.new(
      mangadex_user_id: 'dummy-id'
    )
    expect do
      Mangadex.context.user = api_user
    end.not_to raise_error
    expect(Mangadex.context.user).to eq(api_user)
  end

  it 'sets the user from Mangadex::User' do
    mangadex_user = Mangadex::User.from_data({
      id: 'dummy-id',
      attributes: {
        name: 'thedrummeraki',
      }
    })
    expect do
      Mangadex.context.user = mangadex_user
    end.not_to raise_error
    expect(Mangadex.context.user.mangadex_user_id).to eq('dummy-id')
    expect(Mangadex.context.user.data).to eq(mangadex_user)
  end

  it 'sets the user from Hash' do
    expect do
      Mangadex.context.user = {
        mangadex_user_id: 'dummy-id',
        session: 'session',
        refresh: 'refresh',
      }
    end.not_to raise_error
    expect(Mangadex.context.user.mangadex_user_id).to eq('dummy-id')
    expect(Mangadex.context.user.session).to eq('session')
    expect(Mangadex.context.user.refresh).to eq('refresh')
  end

  it 'fails to set a user from invalid Hash' do
    expect do
      Mangadex.context.user = {
        blah: 'blah',
      }
    end.to raise_error(ArgumentError)
  end

  it 'fails to set a user from the wrong type' do
    expect do
      Mangadex.context.user = 1
    end.to raise_error(TypeError)
  end

  it 'sets a temp user' do
    user_1 = Mangadex::Api::User.new(
      mangadex_user_id: 'one'
    )
    user_2 = Mangadex::Api::User.new(
      mangadex_user_id: 'two'
    )
    Mangadex.context.user = user_1
    expect(Mangadex.context.user.mangadex_user_id).to eq('one')

    Mangadex.context.with_user(user_2) do
      expect(Mangadex.context.user.mangadex_user_id).to eq('two')
    end

    expect(Mangadex.context.user.mangadex_user_id).to eq('one')
  end

  it 'sets temp allowed content ratings' do
    original_content_ratings = Mangadex.context.allow_content_ratings('safe', 'suggestive', 'erotica')

    Mangadex.context.allow_content_ratings('safe') do
      expect(Mangadex.context.allowed_content_ratings).to eq(['safe'])
    end

    expect(Mangadex.context.allowed_content_ratings).to eq(original_content_ratings)
  end

  it 'uses content ratings when calling API' do
    Mangadex.context.allow_content_ratings('pornographic', 'safe')
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
