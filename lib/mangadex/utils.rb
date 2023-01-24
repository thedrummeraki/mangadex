# typed: false

module Mangadex
  class Utils
    class << self
      def camelize(string, uppercase_first_letter = false)
        string.split('_').each_with_index.map do |x, i|
          i == 0 && !uppercase_first_letter ? x : x.capitalize
        end.join
      end

      def underscore(string)
        is_symbol = string.kind_of?(Symbol)
        data = string.to_s
        result = data.gsub(/([A-Z]+)(?=[A-Z][a-z])|([a-z\d])(?=[A-Z])/) do
          ($1 || $2) << "_"
        end.tr('-', '_').downcase

        is_symbol ? result.to_sym : result
      end
    end
  end
end
