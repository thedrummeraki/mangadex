# typed: false
require "active_support/string_inquirer"
require "active_support/core_ext/module/delegation"

module Mangadex
  class ContentRating
    include Comparable

    VALUES = [
      SAFE = 'safe',
      SUGGESTIVE = 'suggestive',
      EROTICA = 'erotica',
      PORNOGRAPHIC = 'pornographic',
    ].freeze

    SCORES = {
      SAFE => 0,
      SUGGESTIVE => 1,
      EROTICA => 2,
      PORNOGRAPHIC => 3,
    }.freeze

    delegate_missing_to :value

    sig { params(content_rating: T::Api::ContentRating).returns(T::Array[ContentRating]) }
    def self.anything_below(content_rating)
      SCORES.keys.map { |key| ContentRating.new(key) }.select { |record| record <= content_rating }.sort
    end

    sig { params(value: T.any(T::Api::Text, T::Api::ContentRating)).void }
    def initialize(value)
      @value = ensure_value!(value.to_s)
    end

    sig { returns(ActiveSupport::StringInquirer) }
    def value
      ActiveSupport::StringInquirer.new(@value)
    end

    sig { params(other: T.any(ContentRating, String, Symbol)).returns(Integer) }
    def <=>(other)
      other_score = if other.is_a?(ContentRating)
        other.score
      else
        ContentRating.new(other).score
      end

      score <=> other_score
    end

    alias_method :safer_than?, :<
    alias_method :spicier_than?, :>

    sig { returns(Integer) }
    def score
      SCORES[value]
    end

    sig { returns(String) }
    def to_s
      value.to_s
    end

    private

    sig { params(value: T.any(T::Api::Text, T::Api::ContentRating)).void }
    def ensure_value!(value)
      return value if value.is_a?(ContentRating)
      return value if VALUES.include?(value)

      raise ArgumentError, "Invalid content rating: '#{value}'. Must be one of #{VALUES}"
    end
  end
end
