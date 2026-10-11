# frozen_string_literal: true

require "test_helper"

# Ported from the crate's `Unix::new` example.
class TestAppStrategyUnix < Minitest::Test
  include EtceteraTest

  def setup
    @strategy = Etcetera::AppStrategy::Unix.new(acme_args)
    @home = Etcetera.home_dir
  end

  def test_home_dir
    assert_equal @home, @strategy.home_dir
  end

  def test_config_dir
    assert_equal @home.join(".frobnicator-plus"), @strategy.config_dir
  end

  def test_data_dir
    assert_equal @home.join(".frobnicator-plus/data"), @strategy.data_dir
  end

  def test_cache_dir
    assert_equal @home.join(".frobnicator-plus/cache"), @strategy.cache_dir
  end

  def test_state_dir
    assert_equal @home.join(".frobnicator-plus/state"), @strategy.state_dir
  end

  def test_runtime_dir
    assert_equal @home.join(".frobnicator-plus/runtime"), @strategy.runtime_dir
  end
end
