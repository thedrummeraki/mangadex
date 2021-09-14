require "active_support/inflector"
require_relative "internal/with_attributes"

module Mangadex
  class MangadexObject
    def initialize(**args)
      args.keys.each do |attribute|
        original_attribute = attribute
        attribute = attribute.to_s.underscore
        attribute_to_set = "#{attribute}="

        if respond_to?(attribute_to_set)
          if %w(created_at updated_at publish_at).include?(attribute)
            args[original_attribute] = DateTime.parse(args[original_attribute])
          end

          send(attribute_to_set, args[original_attribute])
        else
          warn("Ignoring setter `#{attribute_to_set}` on #{self.class.name}...")
        end
      end
    end

    def eq?(other)
      return id == other.id if respond_to?(:id) && other.respond_to?(:id)

      super
    end

    def hash
      id.hash
    end
  end
end
