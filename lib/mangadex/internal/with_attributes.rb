# typed: false

module Mangadex
  module Internal
    module WithAttributes
      extend Concern

      attr_accessor \
          :id,
          :type,
          :attributes,
          :relationships,
          :related_type
      
      class_methods do
        USING_ATTRIBUTES = {}

        def has_attributes(*attributes)
          USING_ATTRIBUTES[self.name] = Array(USING_ATTRIBUTES[self.name]).concat(
            attributes.map(&:to_sym)
          )
        end

        def attributes
          USING_ATTRIBUTES[self.name] || []
        end

        def type
          Mangadex::Utils.underscore(self.name.split('::').last)
        end

        def from_data(data, related_type: nil, source_obj: nil)
          base_class_name = self.name.gsub('::', '_')
          klass_name = self.name
          target_attributes_class_name = "#{base_class_name}_Attributes"

          data = data.transform_keys(&:to_s)

          klass = if const_defined?(target_attributes_class_name)
            Object.const_get(target_attributes_class_name)
          else
            class_contents = <<-END
              # typed: true
              class ::#{target_attributes_class_name} < MangadexObject
                #{USING_ATTRIBUTES[klass_name].map {|attribute| "sig { returns(T.untyped) }; attr_accessor(:#{attribute})"}.join(';')}

                def self.attributes_to_inspect
                  #{USING_ATTRIBUTES[klass_name]}
                end
              end
            END

            eval class_contents
            Object.const_get(target_attributes_class_name)
          end

          relationships = data['relationships']&.map do |relationship_data|
            Relationship.from_data(relationship_data, MangadexObject.new(**data))
          end

          found_attributes = data['attributes'] || {}
          attributes = klass.new(**Hash(found_attributes.symbolize_keys))

          initialize_hash = {
            id: data['id'],
            type: data['type'] || self.type,
            attributes: attributes,
            related_type: related_type,
          }

          relationships = [source_obj].compact unless relationships.present?
          initialize_hash.merge!({relationships: relationships}) if relationships.present?

          # binding.pry

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

        def method_missing(method_name, *args, **kwargs)
          if self.class.attributes.include?(method_name.to_sym)
            return if attributes.nil?
            return unless attributes.respond_to?(method_name)

            attributes.send(method_name)
          elsif any_relationships?
            existing_relationships = relationships.map(&:type)
            looking_for_relationship = method_name.to_s

            if existing_relationships.include?(looking_for_relationship)
              result = relationships.select do |relationship|
                relationship.type == looking_for_relationship
              end
              result.size == 1 ? result.first : result
            else
              super
            end
          elsif !related_type.nil?
            return super unless method_name.end_with?("?")

            looking_for_related = method_name.to_s.split("?").first
            return super unless Mangadex::Relationship::RELATED_VALUES.include?(looking_for_related)

            related_type == looking_for_related
          else
            super
          end
        end
      end
    end
  end
end
