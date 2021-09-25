module Interceptors
  class Base < RequestInterceptor::Application
    before do
      content_type 'application/json'
    end

    after do
      case response.body
      when Array, Hash
        response.body = JSON.generate(response.body)
      end
    end
  end
end
