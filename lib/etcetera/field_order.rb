# frozen_string_literal: true

module Etcetera
  # Orders two values of the same class field by field, the way the crate's
  # derived PartialOrd and Ord do.
  module FieldOrder
    include Comparable

    def <=>(other)
      deconstruct <=> other.deconstruct if other.instance_of?(self.class)
    end
  end
  private_constant :FieldOrder
end
