# frozen_string_literal: true

require "test_helper"

# Like the crate's traits, the interfaces can be implemented by your own
# strategies; see "Custom Conventions" in the crate root documentation.
class TestCustomAppStrategy < Minitest::Test
  # A strategy that implements only the methods the _AppStrategy interface
  # requires, and gets the in_*_dir methods from AppStrategy.
  CUSTOM = Data.define(:home_dir) do
    include Etcetera::AppStrategy

    def config_dir = home_dir.join("config")
    def data_dir = home_dir.join("data")
    def cache_dir = home_dir.join("cache")
    def state_dir = nil
    def runtime_dir = home_dir.join("runtime")
  end

  def setup
    @strategy = CUSTOM.new(home_dir: Pathname.new("/home"))
  end

  def test_in_config_dir
    assert_equal Pathname.new("/home/config/foo/bar"), @strategy.in_config_dir("foo/bar")
  end

  def test_in_data_dir
    assert_equal Pathname.new("/home/data/foo/bar"), @strategy.in_data_dir("foo/bar")
  end

  def test_in_cache_dir
    assert_equal Pathname.new("/home/cache/foo/bar"), @strategy.in_cache_dir("foo/bar")
  end

  def test_in_state_dir_without_a_state_dir
    assert_nil @strategy.in_state_dir("foo/bar")
  end

  def test_in_runtime_dir
    assert_equal Pathname.new("/home/runtime/foo/bar"), @strategy.in_runtime_dir("foo/bar")
  end
end
