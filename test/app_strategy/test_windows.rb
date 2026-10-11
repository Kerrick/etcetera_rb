# frozen_string_literal: true

require "test_helper"

# Ported from the crate's `Windows::new` example. With the environment
# variables gone, Windows asks the Known Folder API while other platforms fall
# back to the Windows default directories.
class TestAppStrategyWindowsWithoutEnvironment < Minitest::Test
  include EtceteraTest

  def setup
    snapshot_env
    clear_strategy_env
    @base = Etcetera::BaseStrategy::Windows.new
    @strategy = Etcetera::AppStrategy::Windows.new(acme_args)
  end

  def teardown
    restore_env
  end

  def test_home_dir
    assert_equal @base.home_dir, @strategy.home_dir
  end

  def test_config_dir
    assert_equal @base.config_dir.join("Acme Corp/Frobnicator Plus/config"), @strategy.config_dir
  end

  def test_data_dir
    assert_equal @base.data_dir.join("Acme Corp/Frobnicator Plus/data"), @strategy.data_dir
  end

  def test_cache_dir
    assert_equal @base.cache_dir.join("Acme Corp/Frobnicator Plus/cache"), @strategy.cache_dir
  end

  def test_state_dir_is_unsupported
    assert_nil @strategy.state_dir
  end

  def test_runtime_dir_is_unsupported
    assert_nil @strategy.runtime_dir
  end
end

# An empty variable is treated as unset, as in the crate, so the strategy ends
# up with the same directories it would have with no variables at all.
class TestAppStrategyWindowsEmptyEnvironment < Minitest::Test
  include EtceteraTest

  def setup
    snapshot_env
    apply_env("APPDATA" => "", "LOCALAPPDATA" => "")
    @base = Etcetera::BaseStrategy::Windows.new
    @strategy = Etcetera::AppStrategy::Windows.new(acme_args)
  end

  def teardown
    restore_env
  end

  def test_config_dir
    assert_equal @base.config_dir.join("Acme Corp/Frobnicator Plus/config"), @strategy.config_dir
  end

  def test_data_dir
    assert_equal @base.data_dir.join("Acme Corp/Frobnicator Plus/data"), @strategy.data_dir
  end

  def test_cache_dir
    assert_equal @base.cache_dir.join("Acme Corp/Frobnicator Plus/cache"), @strategy.cache_dir
  end
end

# Ported from the crate's `Windows::new` example.
class TestAppStrategyWindowsFromEnvironment < Minitest::Test
  include EtceteraTest

  def setup
    snapshot_env
    apply_env(
      "APPDATA" => absolute("/my_data_location"),
      "LOCALAPPDATA" => absolute("/my_cache_location")
    )
    @strategy = Etcetera::AppStrategy::Windows.new(acme_args)
  end

  def teardown
    restore_env
  end

  def test_config_dir
    appdata = Pathname.new(absolute("/my_data_location"))

    assert_equal appdata.join("Acme Corp/Frobnicator Plus/config"), @strategy.config_dir
  end

  def test_data_dir
    appdata = Pathname.new(absolute("/my_data_location"))

    assert_equal appdata.join("Acme Corp/Frobnicator Plus/data"), @strategy.data_dir
  end

  def test_cache_dir
    localappdata = Pathname.new(absolute("/my_cache_location"))

    assert_equal localappdata.join("Acme Corp/Frobnicator Plus/cache"), @strategy.cache_dir
  end
end
