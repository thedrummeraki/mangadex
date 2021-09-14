module Mangadex
  class Relationship < MangadexObject
    attr_accessor :id, :type, :attributes

    class << self
      def from_data(data)
        data = data.with_indifferent_access
        klass = class_for_relationship_type(data['type'])

        return klass.from_data(data) if klass && data['attributes']&.any?

        new(
          id: data['id'],
          type: data['type'],
          attributes: OpenStruct.new(data['attributes']),
        )
      end

      private

      def build_attributes(data)
        klass = class_for_relationship_type(data['type'])
        if klass.present?
          klass.from_data(data)
        else
          OpenStruct.new(data['attributes'])
        end
      end

      def class_for_relationship_type(type)
        module_parts = self.name.split('::')
        module_name = module_parts.take(module_parts.size - 1).join('::')
        klass_name = "#{module_name}::#{type.split('_').collect(&:capitalize).join}"

        return unless Object.const_defined?(klass_name)

        Object.const_get(klass_name)
      end
    end

    def inspect
      "#<#{self.class} id=#{id.inspect} type=#{type.inspect}>"
    end
  end
end