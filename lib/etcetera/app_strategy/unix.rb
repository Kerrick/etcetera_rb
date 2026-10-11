# frozen_string_literal: true

require "pathname"

require_relative "../app_strategy"

module Etcetera
  module AppStrategy
    # This strategy has no standard or official specification. It has arisen
    # over time through hundreds of Unixy tools. Vim and Cargo are notable
    # examples whose configuration/data/cache directory layouts are similar to
    # those created by this strategy.
    #
    #   args = Etcetera::AppStrategy::AppStrategyArgs.new(
    #     top_level_domain: "org",
    #     author: "Acme Corp",
    #     app_name: "Frobnicator Plus"
    #   )
    #   app_strategy = Etcetera::AppStrategy::Unix.new(args)
    #   home_dir = Etcetera.home_dir
    #
    #   app_strategy.home_dir    # => home_dir
    #   app_strategy.config_dir  # => home_dir.join(".frobnicator-plus")
    #   app_strategy.data_dir    # => home_dir.join(".frobnicator-plus/data")
    #   app_strategy.cache_dir   # => home_dir.join(".frobnicator-plus/cache")
    #   app_strategy.state_dir   # => home_dir.join(".frobnicator-plus/state")
    #   app_strategy.runtime_dir # => home_dir.join(".frobnicator-plus/runtime")
    class Unix
      include Etcetera::AppStrategy

      # Create a new Unix app strategy.
      #
      # Raises Etcetera::HomeDirError if the home directory cannot be located.
      def initialize(args)
        @home_dir = Etcetera.home_dir
        @unixy_name = ".#{args.unixy_name}"
      end

      attr_reader :home_dir

      def config_dir
        @home_dir.join(@unixy_name)
      end

      def data_dir
        @home_dir.join(@unixy_name).join("data")
      end

      def cache_dir
        @home_dir.join(@unixy_name).join("cache")
      end

      def state_dir
        @home_dir.join(@unixy_name).join("state")
      end

      def runtime_dir
        @home_dir.join(@unixy_name).join("runtime")
      end
    end
  end
end
