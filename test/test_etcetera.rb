# frozen_string_literal: true

require "test_helper"

# Tests for Etcetera.home_dir, ported from the crate's `home_dir` docs.
class TestEtcetera < Minitest::Test
  include EtceteraTest

  def test_that_it_has_a_version_number
    refute_nil ::Etcetera::VERSION
  end

  def test_home_dir
    assert_equal Pathname.new(Dir.home), Etcetera.home_dir
  end

  def test_home_dir_raises_when_home_cannot_be_found
    Dir.stub :home, -> { raise ArgumentError, "couldn't find home" } do
      assert_raises(Etcetera::HomeDirError) { Etcetera.home_dir }
    end
  end

  def test_home_dir_error_keeps_the_original_error
    Dir.stub :home, -> { raise ArgumentError, "couldn't find home" } do
      error = assert_raises(Etcetera::HomeDirError) { Etcetera.home_dir }

      assert_kind_of ArgumentError, error.cause
    end
  end

  # The crate falls back to getpwuid when HOME is set but empty, while
  # Dir.home reports the empty string; Etcetera does the lookup itself.
  def test_home_dir_falls_back_to_the_password_database_when_home_is_empty
    skip "Windows has no password database to fall back to" if windows_host?

    snapshot_env
    apply_env("HOME" => "")

    assert_equal Pathname.new(Etc.getpwuid(Process.uid).dir), Etcetera.home_dir
  ensure
    restore_env
  end

  # Dir.home takes an empty HOME at its word on Windows, while the crate reads
  # USERPROFILE first; see the README.
  def test_home_dir_raises_when_home_is_empty_on_windows
    skip "only Windows takes an empty HOME at its word" unless windows_host?

    snapshot_env
    apply_env("HOME" => "")

    assert_raises(Etcetera::HomeDirError) { Etcetera.home_dir }
  ensure
    restore_env
  end

  # Like the crate, an unset HOME is not an error on platforms that have a
  # password database.
  def test_home_dir_falls_back_to_the_password_database_when_home_is_unset
    skip "Windows has no password database to fall back to" if windows_host?

    snapshot_env
    ENV.delete("HOME")

    assert_equal Pathname.new(Etc.getpwuid(Process.uid).dir), Etcetera.home_dir
  ensure
    restore_env
  end

  def test_home_dir_error_message
    assert_equal "could not locate home directory", Etcetera::HomeDirError.new.message
  end
end
