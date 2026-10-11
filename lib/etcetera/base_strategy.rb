# frozen_string_literal: true

require "pathname"

module Etcetera
  # These strategies simply provide the user's configuration, data, and cache
  # directories, without knowing about the application specifically.
  #
  # Provides configuration, data, and cache directories of the current user.
  #
  # Every strategy implements this interface: include it in your own class and
  # implement the six methods that raise NotImplementedError.
  module BaseStrategy
    # Returns the current OS's native Etcetera::BaseStrategy.
    #
    # This uses the Windows strategy on Windows, Apple on macOS & iOS, and Xdg
    # everywhere else. This is the convention used by most GUI applications.
    def self.choose_native_strategy
      native_strategy_class.new
    end

    # Returns the current OS's default Etcetera::BaseStrategy.
    #
    # This uses the Windows strategy on Windows, and Xdg everywhere else. This
    # is the convention used by most CLI applications.
    def self.choose_base_strategy
      base_strategy_class.new
    end

    # Gets the home directory of the current user.
    def home_dir
      raise NotImplementedError, "#{self.class} must implement #home_dir"
    end

    # Gets the user's configuration directory.
    def config_dir
      raise NotImplementedError, "#{self.class} must implement #config_dir"
    end

    # Gets the user's data directory.
    def data_dir
      raise NotImplementedError, "#{self.class} must implement #data_dir"
    end

    # Gets the user's cache directory.
    def cache_dir
      raise NotImplementedError, "#{self.class} must implement #cache_dir"
    end

    # Gets the user's state directory.
    # Currently, only the Xdg strategy supports this.
    def state_dir
      raise NotImplementedError, "#{self.class} must implement #state_dir"
    end

    # Gets the user's runtime directory.
    # Currently, only the Xdg strategy supports this.
    #
    # Note: The XDG Base Directory Specification
    # (https://specifications.freedesktop.org/basedir/latest/) places additional
    # requirements on this directory related to ownership, permissions, and
    # persistence. This library does not check these requirements.
    def runtime_dir
      raise NotImplementedError, "#{self.class} must implement #runtime_dir"
    end

    def self.native_strategy_class
      if RUBY_PLATFORM.match?(/darwin/)
        Apple
      elsif WINDOWS_HOST
        Windows
      else
        Xdg
      end
    end

    def self.base_strategy_class
      WINDOWS_HOST ? Windows : Xdg
    end

    private_class_method :native_strategy_class, :base_strategy_class
  end
end
