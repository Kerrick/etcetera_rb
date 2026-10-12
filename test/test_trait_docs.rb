# frozen_string_literal: true

require "test_helper"

# The interfaces' required methods are documented twice: with :method: for
# RDoc, and with @!method for YARD, which rubydoc.info uses. Apart from how
# each links to the strategies, both must say the same thing.
class TestTraitDocs < Minitest::Test
  %w[base_strategy app_strategy].each do |file|
    source = File.read(File.expand_path("../lib/etcetera/#{file}.rb", __dir__))

    rdoc = source.scan(/^ *# :method: (\w+)\n(?: *#.*\n)*? *#\n((?: *#.*\n)*?)\n/).to_h
    yard = source.scan(/^ *# @!method (\w+)\n((?: *#.*\n)*?) *#   @return/).to_h

    define_method("test_#{file}_documents_each_method_for_both") do
      assert_equal rdoc.keys, yard.keys
      assert_equal 6, rdoc.size
    end

    rdoc.each do |name, text|
      define_method("test_#{file}_#{name}_says_the_same_to_both") do
        assert_equal self.class.prose(text), self.class.prose(yard.fetch(name))
      end
    end
  end

  # The words of a comment, without comment markers, escapes or YARD links.
  def self.prose(comment)
    comment.gsub(/^ *#(?: |$)/, "").gsub(/\{\S+ (\w+)\}/, '\1').gsub(/\\(\w)/, '\1').split.join(" ")
  end
end
