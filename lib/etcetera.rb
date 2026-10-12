# frozen_string_literal: true

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

# This is a Ruby library that allows you to determine the locations of configuration, data, cache & other files for your application.
# Existing Ruby libraries generally do not give you a choice in terms of which standards/conventions they follow.
# Etcetera, on the other hand, gives you the choice.
#
# = Conventions
# Etcetera supports the following conventions:
# - the {XDG base directory}[https://standards.freedesktop.org/basedir/latest/]
# - Apple’s {Standard Directories}[https://developer.apple.com/library/content/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html]
# - Window’s {Known Folder Locations}[https://docs.microsoft.com/en-us/windows/win32/shell/knownfolderid]
# - the "Unix Single-folder Convention" i.e. everything in <tt>~/.myapp</tt>
#
# = Strategies
# If you want to get started quickly, you can use the following convenience functions that use the default strategies (as determined arbitrarily by yours truly) or the native strategies for each OS.
#
# == BaseStrategy
# If you just want to get the path to a configuration, data, cache or another directory, you can use the +choose_base_strategy+ function.
#
#   require "etcetera"
#
#   strategy = Etcetera.choose_base_strategy
#
#   config_dir = strategy.config_dir
#   data_dir = strategy.data_dir
#   cache_dir = strategy.cache_dir
#   state_dir = strategy.state_dir
#   runtime_dir = strategy.runtime_dir
#
# == AppStrategy
# If you want to get the path to a configuration, data, cache or another directory, and you want to follow the naming conventions for your application, you can use the +choose_app_strategy+ function.
#
# Let’s take an application created by <tt>Acme Corp</tt> with the name <tt>Frobnicator Plus</tt> and the top-level domain of <tt>org</tt> as an example.
# - XDG strategy would place these in <tt>~/.config/frobnicator-plus</tt>.
# - Unix strategy would place these in <tt>~/.frobnicator-plus</tt>.
# - Apple strategy would place these in <tt>~/Library/Preferences/org.acme-corp.Frobnicator-Plus</tt>.
# - Windows strategy would place these in <tt>~\AppData\Roaming\Acme Corp\Frobnicator Plus</tt>.
#
#   require "etcetera"
#
#   strategy = Etcetera.choose_app_strategy(Etcetera::AppStrategyArgs.new(
#     top_level_domain: "org",
#     author: "Acme Corp",
#     app_name: "Frobnicator Plus"
#   ))
#
#   config_dir = strategy.config_dir
#   data_dir = strategy.data_dir
#   cache_dir = strategy.cache_dir
#   state_dir = strategy.state_dir
#   runtime_dir = strategy.runtime_dir
#
# == Native Strategy
#
# +choose_base_strategy+ and +choose_app_strategy+ will use the +XDG+ strategy on Linux & macOS, and the +Windows+ strategy on \Windows.
# This is used by most CLI tools & some GUI tools on each platform.
#
# If you're developing a GUI application, you might want to use the "Standard directories" on macOS by using +choose_native_strategy+ instead.
# Note that if your application expects the user to modify the configuration files, you should still prefer the +XDG+ strategy on macOS.
#
# == Custom Conventions
#
# You aren’t limited to the built-in conventions – you can implement the relevant modules yourself. Please consider contributing these back, as the more preset conventions there are, the better.
#
# = More Examples
# Say you were a hardened Unix veteran, and didn’t want to have any of this XDG nonsense, clutter in the home directory be damned! Instead of using +choose_app_strategy+ or +choose_base_strategy+, you can pick a strategy yourself. Here’s an example using the AppStrategy::Unix strategy – see its documentation to see what kind of folder structures it produces:
#
#   require "etcetera"
#
#   strategy = Etcetera::AppStrategy::Unix.new(Etcetera::AppStrategyArgs.new(
#     top_level_domain: "com",
#     author: "Hardened Unix Veteran Who Likes Short Command Names",
#     app_name: "wry"
#   ))
#
#   config_dir = strategy.config_dir # produces ~/.wry/
#   # et cetera.
#
# Oftentimes the location of a configuration, data or cache directory is needed solely to create a path that starts inside it. For this purpose, AppStrategy implements a couple of convenience methods for you:
#
#   require "etcetera"
#
#   strategy = Etcetera.choose_app_strategy(Etcetera::AppStrategyArgs.new(
#     top_level_domain: "org",
#     author: "Acme Corp",
#     app_name: "Frobnicator"
#   ))
#
#   # Path to configuration directory.
#   config_dir = strategy.config_dir
#
#   # Path to config.toml inside the configuration directory.
#   config_file = strategy.in_config_dir("config.toml")
#
#   config_dir.join("config.toml") == config_file # => true
module Etcetera
  AppStrategyArgs = AppStrategy::AppStrategyArgs

  # A convenience function that wraps the {home}[https://docs.ruby-lang.org/en/master/Dir.html#method-c-home] function from the standard library.
  def self.home_dir
    Pathname.new(Dir.home)
  rescue ArgumentError
    raise HomeDirError
  end

  # This error occurs when the home directory cannot be located.
  class HomeDirError < StandardError
    def initialize(message = "could not locate home directory")
      super
    end
  end

  # Returns the current OS’s default BaseStrategy.
  # This uses the BaseStrategy::Windows strategy on \Windows, and BaseStrategy::Xdg everywhere else.
  # This is the convention used by most CLI applications.
  def self.choose_base_strategy = BaseStrategy.choose_base_strategy

  # Returns the current OS’s default AppStrategy.
  # This uses the AppStrategy::Windows strategy on \Windows, and AppStrategy::Xdg everywhere else.
  # This is the convention used by most CLI applications.
  def self.choose_app_strategy(args) = AppStrategy.choose_app_strategy(args)
end
