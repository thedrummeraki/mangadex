require "active_support/hash_with_indifferent_access"

module Mangadex
  module Internal
    module WithAttributes
      extend ActiveSupport::Concern

      attr_accessor \
          :id,
          :type,
          :attributes,
          :relationships
      
      class_methods do
        USING_ATTRIBUTES = []

        def has_attributes(*attributes)
          USING_ATTRIBUTES.concat(attributes.map(&:to_sym))
        end

        def type
          self.name.split('::').last.underscore
        end

        def from_data(data)
          base_class_name = self.name.gsub('::', '_')
          target_attributes_class_name = "#{base_class_name}_Attributes"
          
          klass = if const_defined?(target_attributes_class_name)
            target_attributes_class_name.constantize
          else
            klass = Class.new(MangadexObject) do
              attr_accessor *USING_ATTRIBUTES
            end
            Object.const_set(target_attributes_class_name, klass)
          end

          data = data.with_indifferent_access

          relationships = data['relationships']&.map do |relationship_data|
            Relationship.from_data(relationship_data)
          end

          attributes = klass.new(**Hash(data['attributes']))

          initialize_hash = {
            id: data['id'],
            type: data['type'] || self.type,
            attributes: attributes,
          }

          initialize_hash.merge!({relationships: relationships}) if relationships.present?

          new(**initialize_hash)
        end
      end

      included do
        def ==(other)
          if other.is_a?(String)
            id == other
          elsif other.respond_to?(:id)
            id == other.id
          else
            false
          end
        end

        def any_relationships?
          Array(relationships).any?
        end

        def method_missing(method_name)
          if attributes.respond_to?(method_name)
            attributes.send(method_name)
          elsif any_relationships?
            existing_relationships = relationships.map(&:type)
            original_relationship = method_name.to_s
            looking_for_relationship = original_relationship.singularize
            is_looking_for_many = original_relationship != looking_for_relationship

            if existing_relationships.include?(looking_for_relationship)
              search_method = is_looking_for_many ? :select : :find
              relationships.send(search_method) do |relationship|
                relationship.type == looking_for_relationship
              end
            elsif is_looking_for_many
              []
            else
              super
            end
          else
            super
          end
        end
      end
    end
  end
end
