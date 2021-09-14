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

    class << self
      def anything_below(content_rating)
        SCORES.keys.map { |key| ContentRating.new(key) }.select { |record| record <= content_rating }.sort
      end
    end
    
    def initialize(value)
      @value = ensure_value!(value.to_s)
    end

    def value
      ActiveSupport::StringInquirer.new(@value)
    end

    def <=>(other)
      other_score = if other.is_a?(ContentRating)
        other.score
      elsif other.is_a?(String) || other.is_a?(Symbol)
        ContentRating.new(other).score
      else
        raise "Can only compare to ContentRating, String or Symbol. Got #{other.class}"
      end

      score <=> other_score
    end

    alias_method :safer_than?, :<
    alias_method :spicier_than?, :>

    def score
      SCORES[value]
    end

    def to_s
      value.to_s
    end

    private

    def ensure_value!(value)
      return value if VALUES.include?(value)

      raise ArgumentError, "Invalid content rating: '#{value}'. Must be one of #{VALUES}"
    end
  end
end
