# typed: false
module Mangadex
  class Relationship < MangadexObject
    attr_accessor :id, :type, :related, :attributes

    RELATED_VALUES = %w(
      monochrome
      main_story
      adapted_from
      based_on
      prequel
      side_story
      doujinshi
      same_franchise
      shared_universe
      sequel
      spin_off
      alternate_story
      preserialization
      colored
      serialization
    ).freeze

    class << self
      def from_data(data)
        data = data.with_indifferent_access
        klass = class_for_relationship_type(data['type'])

        if klass && data['attributes']&.any?
          return klass.from_data(data, related_type: data['related'])
        end

        new(
          id: data['id'],
          type: data['type'],
          attributes: OpenStruct.new(data['attributes']),
          related: data['related'],
        )
      end

      private

      def class_for_relationship_type(type)
        module_parts = self.name.split('::')
        module_name = module_parts.take(module_parts.size - 1).join('::')
        klass_name = "#{module_name}::#{type.split('_').collect(&:capitalize).join}"

        return unless Object.const_defined?(klass_name)

        Object.const_get(klass_name)
      end
    end

    def self.attributes_to_inspect
      [:id, :type, :related]
    end

    
    def method_missing(value)
      return super unless value.end_with?("?")

      looking_for_related = value.to_s.split("?").first
      return super unless RELATED_VALUES.include?(looking_for_related)

      !related.nil? && related == looking_for_related
    end
  end
end