# frozen_string_literal: true

require "test_helper"

# Ported from the crate's `Apple::new` example.
class TestBaseStrategyApple < Minitest::Test
  include EtceteraTest

  def setup
    @strategy = Etcetera::BaseStrategy::Apple.new
    @home = Etcetera.home_dir
  end

  def test_home_dir
    assert_equal @home, @strategy.home_dir
  end

  def test_config_dir
    assert_equal Pathname.new("Library/Preferences"), @strategy.config_dir.relative_path_from(Etcetera.home_dir)
  end

  def test_data_dir
    assert_equal Pathname.new("Library/Application Support"), @strategy.data_dir.relative_path_from(Etcetera.home_dir)
  end

  def test_cache_dir
    assert_equal Pathname.new("Library/Caches"), @strategy.cache_dir.relative_path_from(Etcetera.home_dir)
  end

  def test_state_dir_is_unsupported
    assert_nil @strategy.state_dir
  end

  def test_runtime_dir_is_unsupported
    assert_nil @strategy.runtime_dir
  end
end
