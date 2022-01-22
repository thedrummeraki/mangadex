# typed: true

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

    sig { returns(T::Api::ConfigCallback) }
    attr_accessor :before_login

    sig { returns(T::Api::ConfigCallback) }
    attr_accessor :after_login

    sig { returns(T::Api::ConfigCallback) }
    attr_accessor :after_refresh

    sig { void }
    def initialize
      @user_class = Api::User
      @storage_class = Storage::Memory
      @default_content_ratings = ContentRating.parse(['safe', 'suggestive', 'erotica'])

      # Authentication callbacks
      @before_login = []
      @after_login = []
      @after_refresh = []
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

    sig { params(before_login: T::Api::ConfigCallback).void }
    def before_login=(before_login)
      @before_login = Array(before_login).uniq
    end

    sig { params(after_login: T::Api::ConfigCallback).void }
    def after_login=(after_login)
      @after_login = Array(after_login).uniq
    end

    sig { params(after_refresh: T::Api::ConfigCallback).void }
    def after_refresh=(after_refresh)
      @after_refresh = Array(after_refresh).uniq
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

    def callback(callback, *args, **kwargs)
      failed_callbacks = []
      send(callback).each do |c|
        send(c, *args, **kwargs)
      rescue StandardError => e
        failed_callbacks << {method: c, reason: e}
      end
      if failed_callbacks.any?
        raise Mangadex::Errors::CallbackError, "Undefined callbacks: #{failed_callbacks}"
      end
      true
    end
  end
end
