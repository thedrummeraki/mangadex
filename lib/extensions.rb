# typed: true

class Array
  def to_query(key)
    prefix = "#{key}[]"

    if empty?
      nil.to_query(prefix)
    else
      collect { |value| value.to_query(prefix) }.join "&"
    end
  end

  def to_param
    collect(&:to_param).join "/"
  end
end

class Hash
  def symbolize_keys
    transform_keys { |key| key.to_sym rescue key }
  end

  def to_query(namespace = nil)
    query = collect do |key, value|
      unless (value.is_a?(Hash) || value.is_a?(Array)) && value.empty?
        value.to_query(namespace ? "#{namespace}[#{key}]" : key)
      end
    end.compact

    query.sort! unless namespace.to_s.include?("[]")
    query.join("&")
  end
  alias_method :to_param, :to_query

  def deep_transform_keys(&block)
    _deep_transform_keys_in_object(self, &block)
  end

  private

  def _deep_transform_keys_in_object(object, &block)
    case object
    when Hash
      object.each_with_object({}) do |(key, value), result|
        result[yield(key)] = _deep_transform_keys_in_object(value, &block)
      end
    when Array
      object.map { |e| _deep_transform_keys_in_object(e, &block) }
    else
      object
    end
  end
end

class Object
  def blank?
    respond_to?(:empty?) ? !!empty? : !self
  end

  def present?
    !blank?
  end

  def presence
    present? ? self : nil
  end

  def to_param
    to_s
  end
end

class NilClass
  def to_param
    self
  end
end

class TrueClass
  def to_param
    self
  end
end

class FalseClass
  def to_param
    self
  end
end

class String
  def to_query(key)
    "#{CGI.escape(key.to_param)}=#{CGI.escape(to_param.to_s)}"
  end

  def to_param
    to_s
  end
end

class Symbol
  def to_query(key)
    "#{CGI.escape(key.to_param)}=#{CGI.escape(to_param.to_s)}"
  end
end

class StringInquirer < String
  private

  def respond_to_missing?(method_name, include_private = false)
    method_name.end_with?("?") || super
  end

  def method_missing(method_name, *arguments)
    if method_name.end_with?("?")
      self == method_name[0..-2]
    else
      super
    end
  end
end

module Concern
  class MultipleIncludedBlocks < StandardError # :nodoc:
    def initialize
      super "Cannot define multiple 'included' blocks for a Concern"
    end
  end

  class MultiplePrependBlocks < StandardError # :nodoc:
    def initialize
      super "Cannot define multiple 'prepended' blocks for a Concern"
    end
  end

  def self.extended(base) # :nodoc:
    base.instance_variable_set(:@_dependencies, [])
  end

  def append_features(base) # :nodoc:
    if base.instance_variable_defined?(:@_dependencies)
      base.instance_variable_get(:@_dependencies) << self
      false
    else
      return false if base < self
      @_dependencies.each { |dep| base.include(dep) }
      super
      base.extend const_get(:ClassMethods) if const_defined?(:ClassMethods)
      base.class_eval(&@_included_block) if instance_variable_defined?(:@_included_block)
    end
  end

  def prepend_features(base) # :nodoc:
    if base.instance_variable_defined?(:@_dependencies)
      base.instance_variable_get(:@_dependencies).unshift self
      false
    else
      return false if base < self
      @_dependencies.each { |dep| base.prepend(dep) }
      super
      base.singleton_class.prepend const_get(:ClassMethods) if const_defined?(:ClassMethods)
      base.class_eval(&@_prepended_block) if instance_variable_defined?(:@_prepended_block)
    end
  end

  def included(base = nil, &block)
    if base.nil?
      if instance_variable_defined?(:@_included_block)
        if @_included_block.source_location != block.source_location
          raise MultipleIncludedBlocks
        end
      else
        @_included_block = block
      end
    else
      super
    end
  end

  def prepended(base = nil, &block)
    if base.nil?
      if instance_variable_defined?(:@_prepended_block)
        if @_prepended_block.source_location != block.source_location
          raise MultiplePrependBlocks
        end
      else
        @_prepended_block = block
      end
    else
      super
    end
  end

  def class_methods(&class_methods_module_definition)
    mod = const_defined?(:ClassMethods, false) ?
      const_get(:ClassMethods) :
      const_set(:ClassMethods, Module.new)

    mod.module_eval(&class_methods_module_definition)
  end
end
