# frozen_string_literal: true

module Etcetera
  # These strategies simply provide the user’s configuration, data, and cache directories, without knowing about the application specifically.
  #
  # Provides configuration, data, and cache directories of the current user.
  module BaseStrategy
    ##
    # :method: home_dir
    # :call-seq:
    #   home_dir -> Pathname
    #
    # Gets the home directory of the current user.

    ##
    # :method: config_dir
    # :call-seq:
    #   config_dir -> Pathname
    #
    # Gets the user’s configuration directory.

    ##
    # :method: data_dir
    # :call-seq:
    #   data_dir -> Pathname
    #
    # Gets the user’s data directory.

    ##
    # :method: cache_dir
    # :call-seq:
    #   cache_dir -> Pathname
    #
    # Gets the user’s cache directory.

    ##
    # :method: state_dir
    # :call-seq:
    #   state_dir -> Pathname or nil
    #
    # Gets the user’s state directory.
    # Currently, only the {Xdg}[rdoc-ref:Etcetera::BaseStrategy::Xdg] strategy supports this.

    ##
    # :method: runtime_dir
    # :call-seq:
    #   runtime_dir -> Pathname or nil
    #
    # Gets the user’s runtime directory.
    # Currently, only the {Xdg}[rdoc-ref:Etcetera::BaseStrategy::Xdg] strategy supports this.
    #
    # Note: The {XDG Base Directory Specification}[https://specifications.freedesktop.org/basedir/latest/] places additional requirements on this
    # directory related to ownership, permissions, and persistence. This library does not check
    # these requirements.

    # Returns the current OS’s native {BaseStrategy}[rdoc-ref:Etcetera::BaseStrategy].
    # This uses the {Windows}[rdoc-ref:Etcetera::BaseStrategy::Windows] strategy on Windows, {Apple}[rdoc-ref:Etcetera::BaseStrategy::Apple] on macOS & iOS, and {Xdg}[rdoc-ref:Etcetera::BaseStrategy::Xdg] everywhere else.
    # This is the convention used by most GUI applications.
    def self.choose_native_strategy
      if Gem.win_platform? then Windows.new
      elsif RUBY_PLATFORM.include?("darwin") then Apple.new
      else Xdg.new
      end
    end

    # Returns the current OS’s default {BaseStrategy}[rdoc-ref:Etcetera::BaseStrategy].
    # This uses the {Windows}[rdoc-ref:Etcetera::BaseStrategy::Windows] strategy on Windows, and {Xdg}[rdoc-ref:Etcetera::BaseStrategy::Xdg] everywhere else.
    # This is the convention used by most CLI applications.
    def self.choose_base_strategy
      Gem.win_platform? ? Windows.new : Xdg.new
    end
  end
end
