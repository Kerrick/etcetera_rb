# frozen_string_literal: true

require "test_helper"

# Tests for the strategy selection functions, ported from the crate's
# "Native strategy" and "Platform-specific strategies" docs.
class TestChooseStrategies < Minitest::Test
  include EtceteraTest

  # The methods of the _BaseStrategy and _AppStrategy interfaces.
  INTERFACE = %i[home_dir config_dir data_dir cache_dir state_dir runtime_dir].freeze

  # The methods AppStrategy provides on top of them.
  IN_DIR_METHODS = %i[in_config_dir in_data_dir in_cache_dir in_state_dir in_runtime_dir].freeze

  def test_choose_base_strategy
    assert_instance_of default_base_class, Etcetera.choose_base_strategy
  end

  def test_choose_app_strategy
    assert_instance_of default_app_class, Etcetera.choose_app_strategy(acme_args)
  end

  def test_choose_native_base_strategy
    assert_instance_of native_base_class, Etcetera::BaseStrategy.choose_native_strategy
  end

  def test_choose_native_app_strategy
    assert_instance_of native_app_class,
                       Etcetera::AppStrategy.choose_native_strategy(acme_args)
  end

  # The crate's `use etcetera::{choose_app_strategy, AppStrategy}` example.
  def test_chosen_strategies_implement_their_interface
    base_strategy = Etcetera.choose_base_strategy
    app_strategy = Etcetera.choose_app_strategy(acme_args)

    INTERFACE.each { assert_respond_to base_strategy, it }
    (INTERFACE + IN_DIR_METHODS).each { assert_respond_to app_strategy, it }
  end

  private

  def default_base_class
    Gem.win_platform? ? Etcetera::BaseStrategy::Windows : Etcetera::BaseStrategy::Xdg
  end

  def default_app_class
    Gem.win_platform? ? Etcetera::AppStrategy::Windows : Etcetera::AppStrategy::Xdg
  end

  def native_base_class
    return Etcetera::BaseStrategy::Windows if Gem.win_platform?

    RUBY_PLATFORM.include?("darwin") ? Etcetera::BaseStrategy::Apple : Etcetera::BaseStrategy::Xdg
  end

  def native_app_class
    return Etcetera::AppStrategy::Windows if Gem.win_platform?

    RUBY_PLATFORM.include?("darwin") ? Etcetera::AppStrategy::Apple : Etcetera::AppStrategy::Xdg
  end
end
