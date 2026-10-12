# frozen_string_literal: true

require "test_helper"
require "open3"
require "rbconfig"

# Runs the examples in the documentation, as the crate runs its doctests: each
# example in a process of its own, with every `# =>` annotation checked against
# the inspected value of the expression before it.
class TestDocExamples < Minitest::Test
  LIB = File.expand_path("../lib", __dir__)

  PRELUDE = <<~RUBY
    def __doc_check(actual, expected, line)
      return if actual.inspect == expected

      abort "line \#{line}: expected \#{expected}, got \#{actual.inspect}"
    end
  RUBY

  # Returns each example in +file+ as an array of [line number, code] pairs.
  # Examples are RDoc verbatim blocks: comment lines indented past the text
  # around them. The block after RDoc's :call-seq: or YARD's @!method is not an
  # example, but the call-seq or the documentation of a method.
  def self.examples(file)
    runs = comment_lines(file).chunk_while { |(_, a), (_, b)| part_of_example?(a) && part_of_example?(b) }
    runs.each_cons(2).filter_map do |before, run|
      example = trim_blank_lines(run)
      next if example.empty? || directive?(before)

      example.map { |number, text| [number, text.delete_prefix("   ")] }
    end
  end

  # Returns each line of +file+ as a [line number, comment text] pair, where the
  # text is nil for a line that is not a comment.
  def self.comment_lines(file)
    File.readlines(file, chomp: true).map.with_index(1) { |line, number| [number, line[/\A\s*#(.*)\z/, 1]] }
  end

  def self.verbatim?(text) = text&.start_with?("   ")

  def self.part_of_example?(text) = verbatim?(text) || text&.strip&.empty?

  def self.directive?(run) = run.last.last&.strip&.match?(/\A(:call-seq:|@!method )/)

  def self.trim_blank_lines(run)
    run.drop_while { |_, text| !verbatim?(text) }.reverse.drop_while { |_, text| !verbatim?(text) }.reverse
  end

  def self.script(example)
    PRELUDE + example.map do |number, code|
      expression, expected = code.split(/\s+# => /, 2)
      expected ? "__doc_check((#{expression}), #{expected.dump}, #{number})" : code
    end.join("\n")
  end

  Dir[File.join(LIB, "**", "*.rb")].each do |file|
    relative = file.delete_prefix("#{LIB}/")
    examples(file).each do |example|
      first_line = example.first.first
      define_method("test_#{relative.gsub(/\W/, "_")}_line_#{first_line}") do
        output, status = Open3.capture2e(RbConfig.ruby, "-I", LIB, "-e", self.class.script(example))

        assert_predicate status, :success?, "#{relative}:#{first_line}\n#{output}"
      end
    end
  end
end
