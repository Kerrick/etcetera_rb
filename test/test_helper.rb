# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "etcetera"

require "minitest/autorun"
require "minitest/mock"

# Shared helpers for Etcetera's tests.
#
# The strategies read process-global environment variables, so each test case
# snapshots the environment in setup and restores it in teardown. For the same
# reason, the suite must not be parallelized.
module EtceteraTest
  # Every environment variable the strategies read, except the ones Dir.home
  # needs to find the home directory.
  STRATEGY_VARS = %w[
    XDG_CONFIG_HOME
    XDG_DATA_HOME
    XDG_CACHE_HOME
    XDG_STATE_HOME
    XDG_RUNTIME_DIR
    APPDATA
    LOCALAPPDATA
  ].freeze

  def snapshot_env
    @env_snapshot = ENV.to_h
  end

  def restore_env
    # A skipped test never took its snapshot, so there is nothing to restore.
    ENV.replace(@env_snapshot) if @env_snapshot
  end

  def clear_strategy_env
    STRATEGY_VARS.each { |name| ENV[name] = nil }
  end

  def apply_env(pairs)
    pairs.each { |name, value| ENV[name] = value }
  end

  def windows_host?
    RUBY_PLATFORM.match?(/mswin|mingw|cygwin/)
  end

  # The Known Folder bindings are private to the Windows strategy. The pure
  # half of them is reached directly so that every platform can check them
  # instead of leaving them to the Windows job.
  def known_folders
    Etcetera::BaseStrategy.const_get(:KnownFolders)
  end

  # The environment and the Known Folder API spell the same Windows directory
  # different ways, so compare them normalized.
  def windows_path(path)
    path.to_s.tr("\\", "/").sub(%r{/\z}, "").downcase
  end

  # Makes a path absolute in a way this platform accepts, mirroring the
  # conditional paths in the crate's documentation examples.
  def absolute(path)
    windows_host? ? "C:#{path}" : path
  end

  # The application used throughout the crate's documentation examples.
  def acme_args
    Etcetera::AppStrategyArgs.new(
      top_level_domain: "org",
      author: "Acme Corp",
      app_name: "Frobnicator Plus"
    )
  end
end
