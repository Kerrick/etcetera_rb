# frozen_string_literal: true

require "test_helper"

# Tests for the strategy selection functions, ported from the crate's
# "Native strategy" and "Platform-specific strategies" docs.
class TestChooseStrategies < Minitest::Test
  include EtceteraTest

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
    assert_kind_of Etcetera::BaseStrategy, Etcetera.choose_base_strategy
    assert_kind_of Etcetera::AppStrategy, Etcetera.choose_app_strategy(acme_args)
  end

  private

  def default_base_class
    windows_host? ? Etcetera::BaseStrategy::Windows : Etcetera::BaseStrategy::Xdg
  end

  def default_app_class
    windows_host? ? Etcetera::AppStrategy::Windows : Etcetera::AppStrategy::Xdg
  end

  def native_base_class
    return Etcetera::BaseStrategy::Windows if windows_host?

    RUBY_PLATFORM.include?("darwin") ? Etcetera::BaseStrategy::Apple : Etcetera::BaseStrategy::Xdg
  end

  def native_app_class
    return Etcetera::AppStrategy::Windows if windows_host?

    RUBY_PLATFORM.include?("darwin") ? Etcetera::AppStrategy::Apple : Etcetera::AppStrategy::Xdg
  end
end
