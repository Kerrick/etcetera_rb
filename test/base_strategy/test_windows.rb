# frozen_string_literal: true

require "test_helper"

# Ported from the crate's `Windows::dir_crt` example. With the environment
# variables gone, Windows asks the Known Folder API while other platforms fall
# back to the Windows default directories.
class TestBaseStrategyWindowsWithoutEnvironment < Minitest::Test
  include EtceteraTest

  def setup
    snapshot_env
    @appdata = ENV["APPDATA"]
    @localappdata = ENV["LOCALAPPDATA"]
    clear_strategy_env
    @strategy = Etcetera::BaseStrategy::Windows.new
    @home = Etcetera.home_dir
  end

  def teardown
    restore_env
  end

  def test_home_dir
    assert_equal Etcetera.home_dir, @strategy.home_dir
  end

  def test_config_dir_matches_data_dir
    assert_equal @strategy.data_dir, @strategy.config_dir
  end

  def test_config_dir
    assert_equal windows_path(expected_roaming), windows_path(@strategy.config_dir)
  end

  def test_data_dir
    assert_equal windows_path(expected_roaming), windows_path(@strategy.data_dir)
    assert_predicate @strategy.data_dir, :absolute?
  end

  def test_cache_dir
    assert_equal windows_path(expected_local), windows_path(@strategy.cache_dir)
    assert_predicate @strategy.cache_dir, :absolute?
  end

  def test_state_dir_is_unsupported
    assert_nil @strategy.state_dir
  end

  def test_runtime_dir_is_unsupported
    assert_nil @strategy.runtime_dir
  end

  private

  # On Windows these come from the Known Folder API, which on a normal install
  # is exactly where APPDATA and LOCALAPPDATA point. Everywhere else the
  # strategy falls back to the Windows defaults under the home directory.
  def expected_roaming
    Gem.win_platform? ? @appdata : @home.join("AppData/Roaming")
  end

  def expected_local
    Gem.win_platform? ? @localappdata : @home.join("AppData/Local")
  end
end

# An empty variable is treated as unset, as in the crate, so this takes the
# same path as having no variable at all.
class TestBaseStrategyWindowsEmptyEnvironment < Minitest::Test
  include EtceteraTest

  def setup
    snapshot_env
    @appdata = ENV["APPDATA"]
    @localappdata = ENV["LOCALAPPDATA"]
    apply_env("APPDATA" => "", "LOCALAPPDATA" => "")
    @strategy = Etcetera::BaseStrategy::Windows.new
    @home = Etcetera.home_dir
  end

  def teardown
    restore_env
  end

  def test_data_dir
    expected = Gem.win_platform? ? @appdata : @home.join("AppData/Roaming")

    assert_equal windows_path(expected), windows_path(@strategy.data_dir)
  end

  def test_cache_dir
    expected = Gem.win_platform? ? @localappdata : @home.join("AppData/Local")

    assert_equal windows_path(expected), windows_path(@strategy.cache_dir)
  end
end

# Ported from the crate's `Windows::dir_env` example.
class TestBaseStrategyWindowsFromEnvironment < Minitest::Test
  include EtceteraTest

  def setup
    snapshot_env
    apply_env(
      "APPDATA" => absolute("/bar"),
      "LOCALAPPDATA" => absolute("/baz")
    )
    @strategy = Etcetera::BaseStrategy::Windows.new
  end

  def teardown
    restore_env
  end

  def test_config_dir
    assert_equal Pathname.new(absolute("/bar")), @strategy.config_dir
  end

  def test_data_dir
    assert_equal Pathname.new(absolute("/bar")), @strategy.data_dir
  end

  def test_cache_dir
    assert_equal Pathname.new(absolute("/baz")), @strategy.cache_dir
  end
end

# The windows-sys bindings, which only Windows loads, as only Windows builds of
# the crate depend on windows-sys.
class TestWindowsSys < Minitest::Test
  # FOLDERID_RoamingAppData and FOLDERID_LocalAppData as they lie in memory.
  ROAMING_BYTES = "db85b63ef965f64ca03ae3ef65729f3d"
  LOCAL_BYTES = "8527b3f1ba6fcf4f9d557b8e7f157091"

  def setup
    skip "only Windows loads windows-sys" unless Gem.win_platform?

    @windows_sys = Etcetera.const_get(:WindowsSys)
  end

  def test_roaming_app_data_guid
    assert_equal ROAMING_BYTES, bytes(@windows_sys::FOLDERID_RoamingAppData)
  end

  def test_local_app_data_guid
    assert_equal LOCAL_BYTES, bytes(@windows_sys::FOLDERID_LocalAppData)
  end

  private

  def bytes(guid) = guid.to_ptr[0, @windows_sys::GUID.size].unpack1("H*")
end

# The C runtime's wcslen, which the crate declares for itself.
class TestCRT < Minitest::Test
  def setup
    skip "only Windows binds wcslen" unless Gem.win_platform?

    @crt = Etcetera::BaseStrategy.const_get(:CRT)
  end

  def test_wcslen_counts_utf16_code_units
    buffer = "C:\\Users\\Ünïcødé".encode(Encoding::UTF_16LE).b + "\x00\x00".b

    assert_equal 16, @crt.wcslen(Fiddle::Pointer[buffer])
  end
end

# Like the crate, only Windows has a Known Folder API to ask.
class TestBaseStrategyWindowsDirCrt < Minitest::Test
  def test_dir_crt_is_nil_off_windows
    skip "the Known Folder API is available here" if Gem.win_platform?

    assert_nil Etcetera::BaseStrategy::Windows.new.send(:dir_crt, "APPDATA")
  end
end

# The strategy half of the Known Folder path, checked on every platform by
# standing in for the API. Only the Fiddle call itself needs Windows.
class TestBaseStrategyWindowsApiResults < Minitest::Test
  include EtceteraTest

  STUBBED = Class.new(Etcetera::BaseStrategy::Windows) do
    private def dir_crt(env)
      { "APPDATA" => "C:/stubbed/Roaming", "LOCALAPPDATA" => "C:/stubbed/Local" }[env]&.then do
        Pathname.new(it)
      end
    end
  end

  def setup
    snapshot_env
    clear_strategy_env
    @strategy = STUBBED.new
  end

  def teardown
    restore_env
  end

  def test_data_dir_comes_from_the_api
    assert_equal Pathname.new("C:/stubbed/Roaming"), @strategy.data_dir
    assert_equal Pathname.new("C:/stubbed/Roaming"), @strategy.config_dir
  end

  def test_cache_dir_comes_from_the_api
    assert_equal Pathname.new("C:/stubbed/Local"), @strategy.cache_dir
  end

  def test_the_environment_still_wins
    apply_env("APPDATA" => absolute("/from_env"))

    assert_equal Pathname.new(absolute("/from_env")), @strategy.data_dir
  end
end

# The Known Folder API itself, which only exists on Windows. This is the one
# test that drives pack_guid, SHGetKnownFolderPath, wide_string and
# CoTaskMemFree end to end, so it fails if any of them is broken.
class TestBaseStrategyWindowsKnownFolderApi < Minitest::Test
  include EtceteraTest

  def setup
    skip "the Known Folder API only exists on Windows" unless Gem.win_platform?

    snapshot_env
    @appdata = ENV["APPDATA"]
    @localappdata = ENV["LOCALAPPDATA"]
    @strategy = Etcetera::BaseStrategy::Windows.new
  end

  def teardown
    restore_env
  end

  def test_dir_crt_returns_the_roaming_app_data_folder
    path = @strategy.send(:dir_crt, "APPDATA")

    refute_nil path, "SHGetKnownFolderPath should return RoamingAppData"
    assert_predicate path, :absolute?
    assert_equal windows_path(@appdata), windows_path(path)
  end

  def test_dir_crt_returns_the_local_app_data_folder
    path = @strategy.send(:dir_crt, "LOCALAPPDATA")

    refute_nil path, "SHGetKnownFolderPath should return LocalAppData"
    assert_predicate path, :absolute?
    assert_equal windows_path(@localappdata), windows_path(path)
  end

  def test_dir_crt_returns_nil_for_an_unknown_variable
    assert_nil @strategy.send(:dir_crt, "XDG_CONFIG_HOME")
  end
end
