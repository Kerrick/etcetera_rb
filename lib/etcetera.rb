# frozen_string_literal: true

require "etc"
require "pathname"

require_relative "etcetera/version"
require_relative "etcetera/base_strategy"
require_relative "etcetera/base_strategy/apple"
require_relative "etcetera/base_strategy/windows"
require_relative "etcetera/base_strategy/xdg"
require_relative "etcetera/app_strategy"
require_relative "etcetera/app_strategy/apple"
require_relative "etcetera/app_strategy/unix"
require_relative "etcetera/app_strategy/windows"
require_relative "etcetera/app_strategy/xdg"

# This is a Ruby library that allows you to determine the locations of
# configuration, data, cache & other files for your application.
# Existing Ruby libraries generally do not give you a choice in terms of which
# standards/conventions they follow. Etcetera, on the other hand, gives you the
# choice.
#
# This library is a port of the Rust +etcetera+ crate
# (https://crates.io/crates/etcetera), and follows its behaviour closely.
#
# == Conventions
#
# Etcetera supports the following conventions:
#
# * the XDG base directory specification
#   (https://standards.freedesktop.org/basedir/latest/)
# * Apple's Standard Directories
#   (https://developer.apple.com/library/content/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html)
# * Windows' Known Folder Locations
#   (https://docs.microsoft.com/en-us/windows/win32/shell/knownfolderid)
# * the "Unix Single-folder Convention" i.e. everything in <tt>~/.myapp</tt>
#
# == Strategies
#
# If you want to get started quickly, you can use the following convenience
# functions that use the default strategies (as determined arbitrarily by yours
# truly) or the native strategies for each OS.
#
# === Etcetera::BaseStrategy
#
# If you just want to get the path to a configuration, data, cache or another
# directory, you can use Etcetera.choose_base_strategy.
#
#   strategy = Etcetera.choose_base_strategy
#
#   config_dir  = strategy.config_dir
#   data_dir    = strategy.data_dir
#   cache_dir   = strategy.cache_dir
#   state_dir   = strategy.state_dir
#   runtime_dir = strategy.runtime_dir
#
# === Etcetera::AppStrategy
#
# If you want to get the path to a configuration, data, cache or another
# directory, and you want to follow the naming conventions for your application,
# you can use Etcetera.choose_app_strategy.
#
# Let's take an application created by <tt>Acme Corp</tt> with the name
# <tt>Frobnicator Plus</tt> and the top-level domain of <tt>org</tt> as an
# example.
#
# * The XDG strategy would place these in <tt>~/.config/frobnicator-plus</tt>.
# * The Unix strategy would place these in <tt>~/.frobnicator-plus</tt>.
# * The Apple strategy would place these in
#   <tt>~/Library/Preferences/org.acme-corp.Frobnicator-Plus</tt>.
# * The Windows strategy would place these in
#   <tt>~\AppData\Roaming\Acme Corp\Frobnicator Plus</tt>.
#
#   args = Etcetera::AppStrategy::AppStrategyArgs.new(
#     top_level_domain: "org",
#     author: "Acme Corp",
#     app_name: "Frobnicator Plus"
#   )
#   strategy = Etcetera.choose_app_strategy(args)
#
#   config_dir  = strategy.config_dir
#   data_dir    = strategy.data_dir
#   cache_dir   = strategy.cache_dir
#   state_dir   = strategy.state_dir
#   runtime_dir = strategy.runtime_dir
#
# === Native strategy
#
# Etcetera.choose_base_strategy and Etcetera.choose_app_strategy will use the
# XDG strategy on Linux & macOS, and the Windows strategy on Windows. This is
# used by most CLI tools & some GUI tools on each platform.
#
# If you're developing a GUI application, you might want to use the "Standard
# directories" on macOS by using BaseStrategy.choose_native_strategy (or
# AppStrategy.choose_native_strategy) instead. Note that if your application
# expects the user to modify the configuration files, you should still prefer
# the XDG strategy on macOS.
#
# === Custom conventions
#
# You aren't limited to the built-in conventions - you can implement the
# relevant interfaces yourself. Please consider contributing these back, as the
# more preset conventions there are, the better.
#
# == More examples
#
# Say you were a hardened Unix veteran, and didn't want to have any of this XDG
# nonsense, clutter in the home directory be damned! Instead of using
# Etcetera.choose_app_strategy or Etcetera.choose_base_strategy, you can pick a
# strategy yourself. Here's an example using the Etcetera::AppStrategy::Unix
# strategy - see its documentation to see what kind of folder structures it
# produces:
#
#   args = Etcetera::AppStrategy::AppStrategyArgs.new(
#     top_level_domain: "com",
#     author: "Hardened Unix Veteran Who Likes Short Command Names",
#     app_name: "wry"
#   )
#   strategy = Etcetera::AppStrategy::Unix.new(args)
#
#   config_dir = strategy.config_dir # produces ~/.wry/
#   # et cetera.
#
# Oftentimes the location of a configuration, data or cache directory is needed
# solely to create a path that starts inside it. For this purpose,
# Etcetera::AppStrategy implements a couple of convenience methods for you:
#
#   args = Etcetera::AppStrategy::AppStrategyArgs.new(
#     top_level_domain: "org",
#     author: "Acme Corp",
#     app_name: "Frobnicator"
#   )
#   strategy = Etcetera.choose_app_strategy(args)
#
#   # Path to configuration directory.
#   config_dir = strategy.config_dir
#
#   # Path to config.toml inside the configuration directory.
#   config_file = strategy.in_config_dir("config.toml")
#
#   config_dir.join("config.toml") == config_file # => true
module Etcetera
  # Shorthand for Etcetera::AppStrategy::AppStrategyArgs, mirroring the crate
  # root re-export this library ports.
  AppStrategyArgs = AppStrategy::AppStrategyArgs

  # Whether the process is running on Windows, where the Known Folder API is
  # available and there is no password database to fall back to.
  WINDOWS_HOST = RUBY_PLATFORM.match?(/mswin|mingw|cygwin/)
  private_constant :WINDOWS_HOST

  # Base class for every error Etcetera raises.
  class Error < StandardError; end

  # This error occurs when the home directory cannot be located.
  class HomeDirError < Error
    def initialize(message = "could not locate home directory")
      super
    end
  end

  # A convenience wrapper around Dir.home that returns a Pathname.
  #
  # Like the crate, the home directory is looked up on every call, and the
  # password database is consulted when the environment does not name one.
  # Unlike Dir.home, a HomeDirError is raised when no home can be found, rather
  # than an ArgumentError.
  def self.home_dir
    home = Dir.home
    home = passwd_home if home.empty? && !WINDOWS_HOST
    raise HomeDirError if home.nil? || home.empty?

    Pathname.new(home)
  rescue ArgumentError
    raise HomeDirError
  end

  # The crate falls back to getpwuid when the environment does not name a home.
  def self.passwd_home
    Etc.getpwuid(Process.uid).dir
  rescue StandardError
    nil
  end
  private_class_method :passwd_home

  # Returns the current OS's default Etcetera::BaseStrategy. See
  # BaseStrategy.choose_base_strategy.
  def self.choose_base_strategy
    BaseStrategy.choose_base_strategy
  end

  # Returns the current OS's default Etcetera::AppStrategy. See
  # AppStrategy.choose_app_strategy.
  def self.choose_app_strategy(args)
    AppStrategy.choose_app_strategy(args)
  end
end
