# frozen_string_literal: true

require "test_helper"

# The crate derives Debug, Clone, PartialEq, Eq and Hash on every strategy, and
# Data provides the same here.
class TestValueSemantics < Minitest::Test
  include EtceteraTest

  BASE_STRATEGIES = [
    Etcetera::BaseStrategy::Apple,
    Etcetera::BaseStrategy::Windows,
    Etcetera::BaseStrategy::Xdg
  ].freeze

  APP_STRATEGIES = [
    Etcetera::AppStrategy::Apple,
    Etcetera::AppStrategy::Unix,
    Etcetera::AppStrategy::Windows,
    Etcetera::AppStrategy::Xdg
  ].freeze

  def strategies
    args = acme_args
    BASE_STRATEGIES.map { |klass| [klass, -> { klass.new }] } +
      APP_STRATEGIES.map { |klass| [klass, -> { klass.new(args) }] }
  end

  def test_equal_strategies_are_equal_and_hash_alike
    strategies.each do |klass, build|
      assert_equal build.call, build.call, klass.name
      assert_equal build.call.hash, build.call.hash, klass.name
      assert_operator build.call, :eql?, build.call
    end
  end

  def test_strategies_of_different_kinds_are_not_equal
    refute_equal Etcetera::BaseStrategy::Apple.new, Etcetera::BaseStrategy::Xdg.new
  end

  def test_different_apps_are_different_strategies
    other = Etcetera::AppStrategyArgs.new(top_level_domain: "org", author: "Acme Corp", app_name: "Other")

    refute_equal Etcetera::AppStrategy::Xdg.new(acme_args), Etcetera::AppStrategy::Xdg.new(other)
  end

  def test_strategies_are_inspectable
    assert_equal "#<data Etcetera::BaseStrategy::Xdg home_dir=#{Etcetera.home_dir.inspect}>",
                 Etcetera::BaseStrategy::Xdg.new.inspect
  end

  def test_strategies_are_frozen
    strategies.each { |klass, build| assert_predicate build.call, :frozen?, klass.name }
  end

  # The crate's fields are private; only the trait methods are public.
  def test_app_strategy_fields_are_private
    refute_respond_to Etcetera::AppStrategy::Apple.new(acme_args), :bundle_id
    refute_respond_to Etcetera::AppStrategy::Unix.new(acme_args), :unixy_name
    refute_respond_to Etcetera::AppStrategy::Windows.new(acme_args), :author_app_name_path
    refute_respond_to Etcetera::AppStrategy::Xdg.new(acme_args), :base_strategy
  end

  # Like the crate's `new`, app strategies are built from an AppStrategyArgs.
  def test_app_strategies_take_app_strategy_args
    APP_STRATEGIES.each do |klass|
      assert_raises(ArgumentError, klass.name) { klass.new }
    end
  end
end

# The crate joins its default directories with a trailing separator, as in
# `home_dir.join(".config/")`, and Pathname#join keeps it just as PathBuf does.
class TestTrailingSeparators < Minitest::Test
  include EtceteraTest

  def setup
    snapshot_env
    clear_strategy_env
  end

  def teardown
    restore_env
  end

  def test_xdg_defaults
    strategy = Etcetera::BaseStrategy::Xdg.new

    assert_equal Etcetera.home_dir.join(".config/"), strategy.config_dir
    assert_equal Etcetera.home_dir.join(".local/state/"), strategy.state_dir
  end

  def test_unix_subdirectories
    strategy = Etcetera::AppStrategy::Unix.new(acme_args)

    assert_equal Etcetera.home_dir.join(".frobnicator-plus/data/"), strategy.data_dir
  end
end
