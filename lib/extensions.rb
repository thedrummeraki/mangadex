require "active_support/hash_with_indifferent_access"

class Hash
  def with_indifferent_access
    ActiveSupport::HashWithIndifferentAccess.new(self)
  end

  def nested_under_indifferent_access
    ActiveSupport::HashWithIndifferentAccess.new(self)
  end
end
