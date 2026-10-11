# frozen_string_literal: true

require "fiddle"

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
    windows_host? ? @appdata : @home.join("AppData/Roaming")
  end

  def expected_local
    windows_host? ? @localappdata : @home.join("AppData/Local")
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
    expected = windows_host? ? @appdata : @home.join("AppData/Roaming")

    assert_equal windows_path(expected), windows_path(@strategy.data_dir)
  end

  def test_cache_dir
    expected = windows_host? ? @localappdata : @home.join("AppData/Local")

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

# The pure half of the Known Folder bindings: GUID packing and UTF-16LE
# decoding. They are checked on every platform, because a wrong byte order or
# a wrong encoding is not something only a Windows run would notice.
class TestKnownFolderBindings < Minitest::Test
  include EtceteraTest

  # FOLDERID_RoamingAppData and FOLDERID_LocalAppData, as the windows-sys
  # version the crate uses defines them.
  ROAMING_BYTES = "db85b63ef965f64ca03ae3ef65729f3d"
  LOCAL_BYTES = "8527b3f1ba6fcf4f9d557b8e7f157091"

  def test_folder_ids_match_the_crate
    assert_equal(
      { "APPDATA" => "3EB685DB-65F9-4CF6-A03A-E3EF65729F3D",
        "LOCALAPPDATA" => "F1B32785-6FBA-4FCF-9D55-7B8E7F157091" },
      known_folders::FOLDER_IDS
    )
  end

  def test_packs_the_roaming_app_data_guid
    assert_equal ROAMING_BYTES, packed(known_folders::FOLDER_IDS["APPDATA"])
  end

  def test_packs_the_local_app_data_guid
    assert_equal LOCAL_BYTES, packed(known_folders::FOLDER_IDS["LOCALAPPDATA"])
  end

  def test_decodes_a_utf16le_path
    assert_equal "C:\\Users\\runner", wide("C:\\Users\\runner")
  end

  def test_decodes_a_non_ascii_path
    assert_equal "C:\\Users\\Ünïcødé", wide("C:\\Users\\Ünïcødé")
  end

  def test_decodes_an_empty_string
    assert_equal "", wide("")
  end

  def test_path_for_is_nil_off_windows
    skip "the Known Folder API is available here" if windows_host?

    assert_nil known_folders.path_for(known_folders::FOLDER_IDS["APPDATA"])
  end

  private

  def packed(folder_id)
    known_folders.send(:pack_guid, folder_id).unpack1("H*")
  end

  def wide(text)
    buffer = text.encode(Encoding::UTF_16LE).b + "\x00\x00".b

    known_folders.send(:wide_string, Fiddle::Pointer[buffer])
  end
end

# The strategy half of the Known Folder path, checked on every platform by
# standing in for the API. Only the Fiddle call itself needs Windows.
class TestBaseStrategyWindowsApiResults < Minitest::Test
  include EtceteraTest

  STUBBED = {
    "3EB685DB-65F9-4CF6-A03A-E3EF65729F3D" => "C:/stubbed/Roaming",
    "F1B32785-6FBA-4FCF-9D55-7B8E7F157091" => "C:/stubbed/Local"
  }.freeze

  def setup
    snapshot_env
    clear_strategy_env
    @strategy = Etcetera::BaseStrategy::Windows.new
  end

  def teardown
    restore_env
  end

  def test_data_dir_comes_from_the_api
    with_api do
      assert_equal Pathname.new("C:/stubbed/Roaming"), @strategy.data_dir
      assert_equal Pathname.new("C:/stubbed/Roaming"), @strategy.config_dir
    end
  end

  def test_cache_dir_comes_from_the_api
    with_api do
      assert_equal Pathname.new("C:/stubbed/Local"), @strategy.cache_dir
    end
  end

  def test_the_environment_still_wins
    apply_env("APPDATA" => absolute("/from_env"))

    with_api do
      assert_equal Pathname.new(absolute("/from_env")), @strategy.data_dir
    end
  end

  private

  def with_api(&block)
    known_folders.stub(:path_for, ->(folder_id) { STUBBED[folder_id] }, &block)
  end
end

# The Known Folder API itself, which only exists on Windows. This is the one
# test that drives pack_guid, SHGetKnownFolderPath, wide_string and
# CoTaskMemFree end to end, so it fails if any of them is broken.
class TestBaseStrategyWindowsKnownFolderApi < Minitest::Test
  include EtceteraTest

  def setup
    skip "the Known Folder API only exists on Windows" unless windows_host?

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
