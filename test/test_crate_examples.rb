# frozen_string_literal: true

require "test_helper"

# Tests for the examples in the crate's crate root documentation.
class TestCrateExamples < Minitest::Test
  include EtceteraTest

  def setup
    snapshot_env
  end

  def teardown
    restore_env
  end

  # The crate's `use etcetera::{choose_base_strategy, BaseStrategy}` example.
  def test_base_strategy_directories
    strategy = Etcetera.choose_base_strategy

    assert_instance_of Pathname, strategy.config_dir
    assert_instance_of Pathname, strategy.data_dir
    assert_instance_of Pathname, strategy.cache_dir
  end

  # The native strategy is XDG everywhere but Windows, and only XDG has the
  # last two directories of the example.
  def test_base_strategy_optional_directories
    apply_env("XDG_RUNTIME_DIR" => absolute("/qux"))
    strategy = Etcetera.choose_base_strategy

    if strategy.is_a?(Etcetera::BaseStrategy::Xdg)
      assert_instance_of Pathname, strategy.state_dir
      assert_equal Pathname.new(absolute("/qux")), strategy.runtime_dir
    else
      assert_nil strategy.state_dir
      assert_nil strategy.runtime_dir
    end
  end

  # The crate's "hardened Unix veteran" example.
  def test_unix_veteran_example
    args = Etcetera::AppStrategyArgs.new(
      top_level_domain: "com",
      author: "Hardened Unix Veteran Who Likes Short Command Names",
      app_name: "wry"
    )

    assert_equal Etcetera.home_dir.join(".wry"), Etcetera::AppStrategy::Unix.new(args).config_dir
  end
end

# Tests for the in_*_dir helpers, ported from the crate's "in_config_dir" docs.
class TestInDirHelpers < Minitest::Test
  include EtceteraTest

  def setup
    @strategy = Etcetera::AppStrategy::Unix.new(acme_args)
    @config_dir = @strategy.config_dir
  end

  def test_in_config_dir
    assert_equal @config_dir.join("foo/bar"), @strategy.in_config_dir("foo/bar")
  end

  # The crate takes P: AsRef<OsStr>, which accepts both kinds.
  def test_in_config_dir_accepts_a_pathname
    assert_equal @config_dir.join("foo/bar"), @strategy.in_config_dir(Pathname.new("foo/bar"))
  end

  def test_in_config_dir_twice
    assert_equal @config_dir.join("foo/bar/baz"), @strategy.in_config_dir("foo/bar").join("baz")
  end

  def test_in_data_dir
    assert_equal @strategy.data_dir.join("foo/bar"), @strategy.in_data_dir("foo/bar")
  end

  def test_in_cache_dir
    assert_equal @strategy.cache_dir.join("foo/bar"), @strategy.in_cache_dir("foo/bar")
  end

  def test_in_state_dir
    assert_equal @strategy.state_dir.join("foo/bar"), @strategy.in_state_dir("foo/bar")
  end

  def test_in_runtime_dir
    assert_equal @strategy.runtime_dir.join("foo/bar"), @strategy.in_runtime_dir("foo/bar")
  end
end

# Tests for the in_*_dir helpers on a platform that lacks those directories.
class TestInDirHelpersForUnsupportedDirectories < Minitest::Test
  include EtceteraTest

  def setup
    @strategy = Etcetera::AppStrategy::Apple.new(acme_args)
  end

  def test_in_state_dir_is_unsupported
    assert_nil @strategy.in_state_dir("foo/bar")
  end

  def test_in_runtime_dir_is_unsupported
    assert_nil @strategy.in_runtime_dir("foo/bar")
  end
end
