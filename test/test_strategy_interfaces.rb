# frozen_string_literal: true

require "test_helper"

# The BaseStrategy interface is a guide to implementors, so its default
# implementations raise, mirroring the crate's trait defaults.
class TestBaseStrategyInterface < Minitest::Test
  def test_home_dir_must_be_implemented
    assert_raises(NotImplementedError) { strategy.home_dir }
  end

  def test_config_dir_must_be_implemented
    assert_raises(NotImplementedError) { strategy.config_dir }
  end

  def test_data_dir_must_be_implemented
    assert_raises(NotImplementedError) { strategy.data_dir }
  end

  def test_cache_dir_must_be_implemented
    assert_raises(NotImplementedError) { strategy.cache_dir }
  end

  def test_state_dir_must_be_implemented
    assert_raises(NotImplementedError) { strategy.state_dir }
  end

  def test_runtime_dir_must_be_implemented
    assert_raises(NotImplementedError) { strategy.runtime_dir }
  end

  private

  def strategy
    @strategy ||= Class.new { include Etcetera::BaseStrategy }.new
  end
end

# The AppStrategy interface is a guide to implementors, so its default
# implementations raise, mirroring the crate's trait defaults.
class TestAppStrategyInterface < Minitest::Test
  def test_home_dir_must_be_implemented
    assert_raises(NotImplementedError) { strategy.home_dir }
  end

  def test_config_dir_must_be_implemented
    assert_raises(NotImplementedError) { strategy.config_dir }
  end

  def test_data_dir_must_be_implemented
    assert_raises(NotImplementedError) { strategy.data_dir }
  end

  def test_cache_dir_must_be_implemented
    assert_raises(NotImplementedError) { strategy.cache_dir }
  end

  def test_state_dir_must_be_implemented
    assert_raises(NotImplementedError) { strategy.state_dir }
  end

  def test_runtime_dir_must_be_implemented
    assert_raises(NotImplementedError) { strategy.runtime_dir }
  end

  def test_in_config_dir_must_be_implemented
    assert_raises(NotImplementedError) { strategy.in_config_dir("foo/bar") }
  end

  def test_in_data_dir_must_be_implemented
    assert_raises(NotImplementedError) { strategy.in_data_dir("foo/bar") }
  end

  def test_in_cache_dir_must_be_implemented
    assert_raises(NotImplementedError) { strategy.in_cache_dir("foo/bar") }
  end

  def test_in_state_dir_must_be_implemented
    assert_raises(NotImplementedError) { strategy.in_state_dir("foo/bar") }
  end

  def test_in_runtime_dir_must_be_implemented
    assert_raises(NotImplementedError) { strategy.in_runtime_dir("foo/bar") }
  end

  private

  def strategy
    @strategy ||= Class.new { include Etcetera::AppStrategy }.new
  end
end
