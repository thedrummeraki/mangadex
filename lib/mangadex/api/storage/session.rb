# typed: false

module Mangadex
  module Api
    module Storage
      class Session
        def initialize(session)
          @session = session
        end

        def set(key, value)
          @session[key] = value
        end

        alias_method :[]=, :set

        def unset(key)
          value = @session[key]
          return if value.nil?

          session[key]
          value
        end

        def [](key)
          @session[key]
        end
      end
    end
  end
end
