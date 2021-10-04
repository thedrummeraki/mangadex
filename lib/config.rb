module Mangadex
  class Config
    extend T::Sig

    # Class used to persist users
    # Must respond to: :session, :refresh, :mangadex_user_id
    sig { returns(Class) }
    attr_accessor :user_class

    # Persisting strategy. See Mangadex::Storage::Base for more details.
    sig { returns(Class) }
    attr_accessor :storage_class

    sig { returns(T::Array[ContentRating]) }
    attr_accessor :default_content_ratings

    sig { void }
    def initialize
      @user_class = Api::User
      @storage_class = Storage::Memory
      @default_content_ratings = ContentRating.parse(['safe', 'suggestive', 'erotica'])
    end

    sig { params(klass: Class).void }
    def user_class=(klass)
      missing_methods = [:session, :refresh, :mangadex_user_id] - klass.instance_methods
      if missing_methods.empty?
        @user_class = klass
      else
        raise ArgumentError, 'user_class must respond to :session, :refresh, :mangadex_user_id'
      end
    end

    sig { params(content_ratings: T::Array[T.any(String, ContentRating)]).void }
    def default_content_ratings=(content_ratings)
      @default_content_ratings = ContentRating.parse(content_ratings)
    end

    def storage_class=(klass)
      @storage = nil
      @storage_class = klass
    end

    def storage
      @storage ||= storage_class.new
    end
  end
end
