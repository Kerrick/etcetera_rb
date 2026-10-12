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

  # The crate wraps the standard library's home_dir, so this wraps Dir.home and
  # follows it wherever HOME leads.
  def test_home_dir_follows_dir_home_when_home_is_unset
    snapshot_env
    ENV.delete("HOME")

    assert_equal Pathname.new(Dir.home), Etcetera.home_dir
  ensure
    restore_env
  end

  def test_home_dir_follows_dir_home_when_home_is_empty
    snapshot_env
    apply_env("HOME" => "")

    assert_equal Pathname.new(Dir.home), Etcetera.home_dir
  ensure
    restore_env
  end

  def test_home_dir_error_message
    assert_equal "could not locate home directory", Etcetera::HomeDirError.new.message
  end
end
