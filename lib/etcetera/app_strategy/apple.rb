# frozen_string_literal: true

require "pathname"

require_relative "../app_strategy"
require_relative "../base_strategy/apple"

module Etcetera
  module AppStrategy
    # This is the strategy created by Apple for use on macOS and iOS devices. It
    # is always used by GUI apps on macOS, and is sometimes used by
    # command-line applications there too. iOS only has GUIs, so all iOS
    # applications follow this strategy. The specification is available here
    # (https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html#//apple_ref/doc/uid/TP40010672-CH2-SW1).
    #
    #   args = Etcetera::AppStrategy::AppStrategyArgs.new(
    #     top_level_domain: "org",
    #     author: "Acme Corp",
    #     app_name: "Frobnicator Plus"
    #   )
    #   app_strategy = Etcetera::AppStrategy::Apple.new(args)
    #   home_dir = Etcetera.home_dir
    #
    #   app_strategy.home_dir   # => home_dir
    #   app_strategy.config_dir # => home_dir.join("Library/Preferences/org.acme-corp.Frobnicator-Plus")
    #   app_strategy.data_dir   # => home_dir.join("Library/Application Support/org.acme-corp.Frobnicator-Plus")
    #   app_strategy.cache_dir  # => home_dir.join("Library/Caches/org.acme-corp.Frobnicator-Plus")
    #   app_strategy.state_dir  # => nil
    #   app_strategy.runtime_dir # => nil
    class Apple
      include Etcetera::AppStrategy

      # Create a new Apple app strategy.
      #
      # Raises Etcetera::HomeDirError if the home directory cannot be located.
      def initialize(args)
        @base_strategy = Etcetera::BaseStrategy::Apple.new
        @bundle_id = args.bundle_id
      end

      def home_dir
        @base_strategy.home_dir
      end

      def config_dir
        @base_strategy.config_dir.join(@bundle_id)
      end

      def data_dir
        @base_strategy.data_dir.join(@bundle_id)
      end

      def cache_dir
        @base_strategy.cache_dir.join(@bundle_id)
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
