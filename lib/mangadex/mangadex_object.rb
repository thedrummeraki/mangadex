# typed: false
require_relative "internal/with_attributes"

module Mangadex
  class MangadexObject
    extend T::Sig
    include Internal::WithAttributes

    def self.attributes_to_inspect
      to_inspect = [:id, :type]
      if self.respond_to?(:inspect_attributes)
        to_inspect.concat(Array(self.inspect_attributes))
      end

      to_inspect
    end

    def initialize(**args)
      args.keys.each do |attribute|
        original_attribute = attribute
        attribute = Mangadex::Utils.underscore(attribute.to_s)
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

      self.type = self.class.type if self.type.blank?
    end

    def eq?(other)
      return id == other.id if respond_to?(:id) && other.respond_to?(:id)

      super
    end

    def hash
      id.hash
    end

    def inspect
      string = "#<#{self.class.name}:#{self.object_id} "
      fields = self.class.attributes_to_inspect.map do |field|
        value = self.send(field)
        if !value.nil?
          "@#{field}=\"#{value}\""
        end
      rescue => error
        "@#{field}[!]={#{error.class.name}: #{error.message}}"
      end.compact
      string << fields.join(" ") << ">"
    end
  end
end
