# frozen_string_literal: true

require "pathname"

require_relative "../base_strategy"

module Etcetera
  module BaseStrategy
    # This is the strategy created by Apple for use on macOS and iOS devices. It
    # is always used by GUI apps on macOS, and is sometimes used by
    # command-line applications there too. iOS only has GUIs, so all iOS
    # applications follow this strategy. The specification is available here
    # (https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html#//apple_ref/doc/uid/TP40010672-CH2-SW1).
    #
    #   base_strategy = Etcetera::BaseStrategy::Apple.new
    #   home_dir = Etcetera.home_dir
    #
    #   base_strategy.home_dir    # => home_dir
    #   base_strategy.config_dir  # => home_dir.join("Library/Preferences")
    #   base_strategy.data_dir    # => home_dir.join("Library/Application Support")
    #   base_strategy.cache_dir   # => home_dir.join("Library/Caches")
    #   base_strategy.state_dir   # => nil
    #   base_strategy.runtime_dir # => nil
    class Apple
      include Etcetera::BaseStrategy

      # Create a new Apple base strategy.
      #
      # Raises Etcetera::HomeDirError if the home directory cannot be located.
      def initialize
        @home_dir = Etcetera.home_dir
      end

      attr_reader :home_dir

      def config_dir
        home_dir.join("Library/Preferences")
      end

      def data_dir
        home_dir.join("Library/Application Support")
      end

      def cache_dir
        home_dir.join("Library/Caches")
      end

      def state_dir
        nil
      end

      def runtime_dir
        nil
      end
    end
  end
end
