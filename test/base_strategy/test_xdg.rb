# frozen_string_literal: true

require "test_helper"

# Ported from the crate's `Xdg::default` example.
class TestBaseStrategyXdgDefaults < Minitest::Test
  include EtceteraTest

  def setup
    snapshot_env
    clear_strategy_env
    @strategy = Etcetera::BaseStrategy::Xdg.new
    @home = Etcetera.home_dir
  end

  def teardown
    restore_env
  end

  def test_home_dir
    assert_equal @home, @strategy.home_dir
  end

  def test_config_dir
    assert_equal Pathname.new(".config"), @strategy.config_dir.relative_path_from(Etcetera.home_dir)
  end

  def test_data_dir
    assert_equal Pathname.new(".local/share"), @strategy.data_dir.relative_path_from(Etcetera.home_dir)
  end

  def test_cache_dir
    assert_equal Pathname.new(".cache"), @strategy.cache_dir.relative_path_from(Etcetera.home_dir)
  end

  def test_state_dir
    assert_equal Pathname.new(".local/state"), @strategy.state_dir.relative_path_from(Etcetera.home_dir)
  end

  def test_runtime_dir_is_unsupported_without_the_variable
    assert_nil @strategy.runtime_dir
  end
end

# Ported from the crate's `Xdg::env_var_or_none` example.
class TestBaseStrategyXdgFromEnvironment < Minitest::Test
  include EtceteraTest

  def setup
    snapshot_env
    apply_env(
      "XDG_CONFIG_HOME" => absolute("/foo"),
      "XDG_DATA_HOME" => absolute("/bar"),
      "XDG_CACHE_HOME" => absolute("/baz"),
      "XDG_STATE_HOME" => absolute("/qux"),
      "XDG_RUNTIME_DIR" => absolute("/fizz/buzz")
    )
    @strategy = Etcetera::BaseStrategy::Xdg.new
  end

  def teardown
    restore_env
  end

  def test_config_dir
    assert_equal Pathname.new(absolute("/foo")), @strategy.config_dir
  end

  def test_data_dir
    assert_equal Pathname.new(absolute("/bar")), @strategy.data_dir
  end

  def test_cache_dir
    assert_equal Pathname.new(absolute("/baz")), @strategy.cache_dir
  end

  def test_state_dir
    assert_equal Pathname.new(absolute("/qux")), @strategy.state_dir
  end

  def test_runtime_dir
    assert_equal Pathname.new(absolute("/fizz/buzz")), @strategy.runtime_dir
  end
end

# Ported from the crate's `Xdg::env_var_or_none` example, which ignores
# relative paths.
class TestBaseStrategyXdgRelativeEnvironment < Minitest::Test
  include EtceteraTest

  def setup
    snapshot_env
    apply_env(
      "XDG_CONFIG_HOME" => "relative_path",
      "XDG_DATA_HOME" => "./another_one",
      "XDG_CACHE_HOME" => "yet_another",
      "XDG_STATE_HOME" => "./and_another",
      "XDG_RUNTIME_DIR" => "relative_path"
    )
    @strategy = Etcetera::BaseStrategy::Xdg.new
    @home = Etcetera.home_dir
  end

  def teardown
    restore_env
  end

  def test_config_dir
    assert_equal Pathname.new(".config"), @strategy.config_dir.relative_path_from(Etcetera.home_dir)
  end

  def test_data_dir
    assert_equal Pathname.new(".local/share"), @strategy.data_dir.relative_path_from(Etcetera.home_dir)
  end

  def test_cache_dir
    assert_equal Pathname.new(".cache"), @strategy.cache_dir.relative_path_from(Etcetera.home_dir)
  end

  def test_state_dir
    assert_equal Pathname.new(".local/state"), @strategy.state_dir.relative_path_from(Etcetera.home_dir)
  end

  def test_runtime_dir
    assert_nil @strategy.runtime_dir
  end
end

# An empty variable is treated as unset, as in the crate.
class TestBaseStrategyXdgEmptyEnvironment < Minitest::Test
  include EtceteraTest

  def setup
    snapshot_env
    apply_env("XDG_CONFIG_HOME" => "")
    @strategy = Etcetera::BaseStrategy::Xdg.new
  end

  def teardown
    restore_env
  end

  def test_config_dir
    assert_equal Pathname.new(".config"), @strategy.config_dir.relative_path_from(Etcetera.home_dir)
  end
end
