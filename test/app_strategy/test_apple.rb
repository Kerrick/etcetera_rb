# frozen_string_literal: true

require "test_helper"

# Ported from the crate's `Apple::new` example.
class TestAppStrategyApple < Minitest::Test
  include EtceteraTest

  def setup
    @strategy = Etcetera::AppStrategy::Apple.new(acme_args)
    @home = Etcetera.home_dir
  end

  def test_home_dir
    assert_equal @home, @strategy.home_dir
  end

  def test_config_dir
    assert_equal @home.join("Library/Preferences/org.acme-corp.Frobnicator-Plus"),
                 @strategy.config_dir
  end

  def test_data_dir
    assert_equal @home.join("Library/Application Support/org.acme-corp.Frobnicator-Plus"),
                 @strategy.data_dir
  end

  def test_cache_dir
    assert_equal @home.join("Library/Caches/org.acme-corp.Frobnicator-Plus"), @strategy.cache_dir
  end

  def test_state_dir_is_unsupported
    assert_nil @strategy.state_dir
  end

  def test_runtime_dir_is_unsupported
    assert_nil @strategy.runtime_dir
  end
end
