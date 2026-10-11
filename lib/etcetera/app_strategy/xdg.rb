# frozen_string_literal: true

require "pathname"

require_relative "../app_strategy"
require_relative "../base_strategy/xdg"

module Etcetera
  module AppStrategy
    # This strategy implements the XDG Base Directories Specification
    # (https://specifications.freedesktop.org/basedir/latest/). It is the most
    # common on Linux, but is increasingly being adopted elsewhere.
    #
    # This initial example removes all the XDG environment variables to show the
    # strategy's use of the XDG default directories.
    #
    #   %w[
    #     XDG_CONFIG_HOME XDG_DATA_HOME XDG_CACHE_HOME XDG_STATE_HOME XDG_RUNTIME_DIR
    #   ].each { |name| ENV.delete(name) }
    #
    #   args = Etcetera::AppStrategy::AppStrategyArgs.new(
    #     top_level_domain: "org",
    #     author: "Acme Corp",
    #     app_name: "Frobnicator Plus"
    #   )
    #   app_strategy = Etcetera::AppStrategy::Xdg.new(args)
    #   home_dir = Etcetera.home_dir
    #
    #   app_strategy.home_dir    # => home_dir
    #   app_strategy.config_dir  # => home_dir.join(".config/frobnicator-plus")
    #   app_strategy.data_dir    # => home_dir.join(".local/share/frobnicator-plus")
    #   app_strategy.cache_dir   # => home_dir.join(".cache/frobnicator-plus")
    #   app_strategy.state_dir   # => home_dir.join(".local/state/frobnicator-plus")
    #   app_strategy.runtime_dir # => nil
    #
    # This next example gives the environment variables values. (They must be
    # absolute paths, so use <tt>C:/my_config_location</tt> and friends on
    # Windows.)
    #
    #   ENV["XDG_CONFIG_HOME"] = "/my_config_location"
    #   ENV["XDG_DATA_HOME"]   = "/my_data_location"
    #   ENV["XDG_CACHE_HOME"]  = "/my_cache_location"
    #   ENV["XDG_STATE_HOME"]  = "/my_state_location"
    #   ENV["XDG_RUNTIME_DIR"] = "/my_runtime_location"
    #
    #   args = Etcetera::AppStrategy::AppStrategyArgs.new(
    #     top_level_domain: "org",
    #     author: "Acme Corp",
    #     app_name: "Frobnicator Plus"
    #   )
    #   app_strategy = Etcetera::AppStrategy::Xdg.new(args)
    #
    #   app_strategy.config_dir  # => Pathname.new("/my_config_location/frobnicator-plus")
    #   app_strategy.data_dir    # => Pathname.new("/my_data_location/frobnicator-plus")
    #   app_strategy.cache_dir   # => Pathname.new("/my_cache_location/frobnicator-plus")
    #   app_strategy.state_dir   # => Pathname.new("/my_state_location/frobnicator-plus")
    #   app_strategy.runtime_dir # => Pathname.new("/my_runtime_location/frobnicator-plus")
    #
    # The XDG spec requires that when the environment variables' values are not
    # absolute paths, their values should be ignored. This example exemplifies
    # this behaviour:
    #
    #   ENV["XDG_CONFIG_HOME"] = "relative_path"
    #   ENV["XDG_DATA_HOME"]   = "./another_one"
    #   ENV["XDG_CACHE_HOME"]  = "yet_another"
    #   ENV["XDG_STATE_HOME"]  = "./and_another"
    #   ENV["XDG_RUNTIME_DIR"] = "relative_path"
    #
    #   args = Etcetera::AppStrategy::AppStrategyArgs.new(
    #     top_level_domain: "org",
    #     author: "Acme Corp",
    #     app_name: "Frobnicator Plus"
    #   )
    #   app_strategy = Etcetera::AppStrategy::Xdg.new(args)
    #   home_dir = Etcetera.home_dir
    #
    #   # We still get the default values.
    #   app_strategy.config_dir  # => home_dir.join(".config/frobnicator-plus")
    #   app_strategy.data_dir    # => home_dir.join(".local/share/frobnicator-plus")
    #   app_strategy.cache_dir   # => home_dir.join(".cache/frobnicator-plus")
    #   app_strategy.state_dir   # => home_dir.join(".local/state/frobnicator-plus")
    #   app_strategy.runtime_dir # => nil
    class Xdg
      include Etcetera::AppStrategy

      # Create a new Xdg app strategy.
      #
      # Raises Etcetera::HomeDirError if the home directory cannot be located.
      def initialize(args)
        @base_strategy = Etcetera::BaseStrategy::Xdg.new
        @unixy_name = args.unixy_name
      end

      def home_dir
        @base_strategy.home_dir
      end

      def config_dir
        @base_strategy.config_dir.join(@unixy_name)
      end

      def data_dir
        @base_strategy.data_dir.join(@unixy_name)
      end

      def cache_dir
        @base_strategy.cache_dir.join(@unixy_name)
      end

      def state_dir
        @base_strategy.state_dir.join(@unixy_name)
      end

      def runtime_dir
        @base_strategy.runtime_dir&.join(@unixy_name)
      end
    end
  end
end
