# frozen_string_literal: true

require "test_helper"

# Ported from the crate's `Xdg::default` example.
class TestAppStrategyXdgDefaults < Minitest::Test
  include EtceteraTest

  def setup
    snapshot_env
    clear_strategy_env
    @strategy = Etcetera::AppStrategy::Xdg.new(acme_args)
    @home = Etcetera.home_dir
  end

  def teardown
    restore_env
  end

  def test_home_dir
    assert_equal @home, @strategy.home_dir
  end

  def test_config_dir
    assert_equal Pathname.new(".config/frobnicator-plus"), @strategy.config_dir.relative_path_from(Etcetera.home_dir)
  end

  def test_data_dir
    assert_equal Pathname.new(".local/share/frobnicator-plus"), @strategy.data_dir.relative_path_from(Etcetera.home_dir)
  end

  def test_cache_dir
    assert_equal Pathname.new(".cache/frobnicator-plus"), @strategy.cache_dir.relative_path_from(Etcetera.home_dir)
  end

  def test_state_dir
    assert_equal Pathname.new(".local/state/frobnicator-plus"),
                 @strategy.state_dir.relative_path_from(Etcetera.home_dir)
  end

  def test_runtime_dir_is_unsupported_without_the_variable
    assert_nil @strategy.runtime_dir
  end
end

# Ported from the crate's `Xdg::new` example.
class TestAppStrategyXdgFromEnvironment < Minitest::Test
  include EtceteraTest

  def setup
    snapshot_env
    apply_env(
      "XDG_CONFIG_HOME" => absolute("/my_config_location"),
      "XDG_DATA_HOME" => absolute("/my_data_location"),
      "XDG_CACHE_HOME" => absolute("/my_cache_location"),
      "XDG_STATE_HOME" => absolute("/my_state_location"),
      "XDG_RUNTIME_DIR" => absolute("/my_runtime_location")
    )
    @strategy = Etcetera::AppStrategy::Xdg.new(acme_args)
  end

  def teardown
    restore_env
  end

  def test_config_dir
    assert_equal Pathname.new(absolute("/my_config_location")).join("frobnicator-plus"),
                 @strategy.config_dir
  end

  def test_data_dir
    assert_equal Pathname.new(absolute("/my_data_location")).join("frobnicator-plus"),
                 @strategy.data_dir
  end

  def test_cache_dir
    assert_equal Pathname.new(absolute("/my_cache_location")).join("frobnicator-plus"),
                 @strategy.cache_dir
  end

  def test_state_dir
    assert_equal Pathname.new(absolute("/my_state_location")).join("frobnicator-plus"),
                 @strategy.state_dir
  end

  def test_runtime_dir
    assert_equal Pathname.new(absolute("/my_runtime_location")).join("frobnicator-plus"),
                 @strategy.runtime_dir
  end
end

# Ported from the crate's `Xdg::new` example, which ignores relative paths.
class TestAppStrategyXdgRelativeEnvironment < Minitest::Test
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
    @strategy = Etcetera::AppStrategy::Xdg.new(acme_args)
    @home = Etcetera.home_dir
  end

  def teardown
    restore_env
  end

  def test_config_dir
    assert_equal Pathname.new(".config/frobnicator-plus"), @strategy.config_dir.relative_path_from(Etcetera.home_dir)
  end

  def test_data_dir
    assert_equal Pathname.new(".local/share/frobnicator-plus"), @strategy.data_dir.relative_path_from(Etcetera.home_dir)
  end

  def test_cache_dir
    assert_equal Pathname.new(".cache/frobnicator-plus"), @strategy.cache_dir.relative_path_from(Etcetera.home_dir)
  end

  def test_state_dir
    assert_equal Pathname.new(".local/state/frobnicator-plus"),
                 @strategy.state_dir.relative_path_from(Etcetera.home_dir)
  end

  def test_runtime_dir
    assert_nil @strategy.runtime_dir
  end
end
