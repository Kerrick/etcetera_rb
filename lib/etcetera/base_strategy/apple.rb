# frozen_string_literal: true

module Etcetera
  module BaseStrategy
    # This is the strategy created by \Apple for use on macOS and iOS devices. It is always used by GUI apps on macOS, and is sometimes used by command-line applications there too. iOS only has GUIs, so all iOS applications follow this strategy. The specification is available {here}[https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html#//apple_ref/doc/uid/TP40010672-CH2-SW1].
    #
    #   require "etcetera"
    #
    #   base_strategy = Etcetera::BaseStrategy::Apple.new
    #
    #   home_dir = Etcetera.home_dir
    #
    #   base_strategy.home_dir == home_dir # => true
    #   base_strategy.config_dir.relative_path_from(home_dir) # => #<Pathname:Library/Preferences>
    #   base_strategy.data_dir.relative_path_from(home_dir) # => #<Pathname:Library/Application Support>
    #   base_strategy.cache_dir.relative_path_from(home_dir) # => #<Pathname:Library/Caches>
    #   base_strategy.state_dir # => nil
    #   base_strategy.runtime_dir # => nil
    class Apple < Data.define(:home_dir)
      # Create a new \Apple \BaseStrategy
      def initialize(home_dir: Etcetera.home_dir) = super

      def config_dir = home_dir.join("Library/Preferences/")

      def data_dir = home_dir.join("Library/Application Support/")

      def cache_dir = home_dir.join("Library/Caches/")

      def state_dir = nil

      def runtime_dir = nil
    end
  end
end
