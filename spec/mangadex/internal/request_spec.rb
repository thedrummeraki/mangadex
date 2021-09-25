# typed: ignore

RSpec.describe Mangadex::Internal::Request do
  it 'performs a get request' do
    with_interceptor do
      response = Mangadex::Internal::Request.get('/test')
      expect(response).to eq({"test" => true, "method" => "get", "params" => {}})
    end
  end

  it 'performs a get request with params' do
    with_interceptor do
      response = Mangadex::Internal::Request.get('/test?a=one&b=two')
      expect(response).to eq({
        "test" => true,
        "method" => "get",
        "params" => {"a" => "one", "b" => "two"},
      })
    end
  end

  it 'performs a post request' do
    with_interceptor do
      response = Mangadex::Internal::Request.post('/test')
      expect(response).to eq({"test" => true, "method" => "post"})
    end
  end

  # it 'performs a post request with payload'

  it 'performs a put request' do
    with_interceptor do
      response = Mangadex::Internal::Request.put('/test')
      expect(response).to eq({"test" => true, "method" => "put"})
    end
  end

  it 'performs a delete request' do
    with_interceptor do
      response = Mangadex::Internal::Request.delete('/test')
      expect(response).to eq({"test" => true, "method" => "delete"})
    end
  end

  describe '#initialize' do
    it 'sets all params' do
      client = Mangadex::Internal::Request.new(
        '/test/path',
        method: :get,
        headers: { Header1: 'yes' },
        payload: { param: 'one' },
      )

      payload = JSON.parse(client.request.payload.read)

      expect(client.request.headers[:Header1]).to eq('yes')
      expect(payload['param']).to eq('one')
      expect(client.request.method).to eq('get')
    end

    it 'add the Authorization header if logged in' do
      Mock::User.with_logged_in_user do |user|
        client = Mangadex::Internal::Request.new(
          '/test/path',
          method: :get,
          headers: { Header1: 'yes' },
          payload: { param: 'one' },
        )

        expect(client.request.headers[:Header1]).to eq('yes')
        expect(client.request.headers[:Authorization]).to eq(user.session)
      end
    end
  end

  describe "with errors" do
    it 'returns the body on error if the body is valid json' do
      with_interceptor do
        response = Mangadex::Internal::Request.get('/fail/with/body')
        expect(response).to eq({"error" => true, "body" => "yello"})
      end
    end

    it 'raises an exception if no valid json was returned on error' do
      with_interceptor do
        expect do
          Mangadex::Internal::Request.get('/fail/without/body')
        end.to raise_error(RestClient::Exception)
      end
    end
  end

  private

  def with_interceptor(&block)
    Interceptors::Mangadex.customize do
      get '/test' do
        {test: true, method: :get, params: params}
      end
      post '/test' do
        {test: true, method: :post}
      end
      put '/test' do
        {test: true, method: :put}
      end
      delete '/test' do
        {test: true, method: :delete}
      end

      get '/fail/with/body' do
        [500, {error: true, body: 'yello'}]
      end
      get '/fail/without/body' do
        500
      end
    end.intercept do
      yield
    end
  end
end
