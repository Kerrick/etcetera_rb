# frozen_string_literal: true

module Etcetera
  # These strategies simply provide the user’s configuration, data, and cache directories, without knowing about the application specifically.
  #
  # Provides configuration, data, and cache directories of the current user.
  module BaseStrategy
    # Gets the home directory of the current user.
    def home_dir = raise(NotImplementedError, "#{self.class} must implement #home_dir")

    # Gets the user’s configuration directory.
    def config_dir = raise(NotImplementedError, "#{self.class} must implement #config_dir")

    # Gets the user’s data directory.
    def data_dir = raise(NotImplementedError, "#{self.class} must implement #data_dir")

    # Gets the user’s cache directory.
    def cache_dir = raise(NotImplementedError, "#{self.class} must implement #cache_dir")

    # Gets the user’s state directory.
    # Currently, only the {Xdg}[rdoc-ref:Etcetera::BaseStrategy::Xdg] strategy supports this.
    def state_dir = raise(NotImplementedError, "#{self.class} must implement #state_dir")

    # Gets the user’s runtime directory.
    # Currently, only the {Xdg}[rdoc-ref:Etcetera::BaseStrategy::Xdg] strategy supports this.
    #
    # Note: The {XDG Base Directory Specification}[https://specifications.freedesktop.org/basedir/latest/] places additional requirements on this
    # directory related to ownership, permissions, and persistence. This library does not check
    # these requirements.
    def runtime_dir = raise(NotImplementedError, "#{self.class} must implement #runtime_dir")

    # Returns the current OS’s native {BaseStrategy}[rdoc-ref:Etcetera::BaseStrategy].
    # This uses the {Windows}[rdoc-ref:Etcetera::BaseStrategy::Windows] strategy on Windows, {Apple}[rdoc-ref:Etcetera::BaseStrategy::Apple] on macOS & iOS, and {Xdg}[rdoc-ref:Etcetera::BaseStrategy::Xdg] everywhere else.
    # This is the convention used by most GUI applications.
    def self.choose_native_strategy
      if WINDOWS_HOST then Windows.new
      elsif RUBY_PLATFORM.include?("darwin") then Apple.new
      else Xdg.new
      end
    end

    # Returns the current OS’s default {BaseStrategy}[rdoc-ref:Etcetera::BaseStrategy].
    # This uses the {Windows}[rdoc-ref:Etcetera::BaseStrategy::Windows] strategy on Windows, and {Xdg}[rdoc-ref:Etcetera::BaseStrategy::Xdg] everywhere else.
    # This is the convention used by most CLI applications.
    def self.choose_base_strategy
      WINDOWS_HOST ? Windows.new : Xdg.new
    end
  end
end
