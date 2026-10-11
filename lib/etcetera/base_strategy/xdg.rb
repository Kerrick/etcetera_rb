# frozen_string_literal: true

require "pathname"

require_relative "../base_strategy"

module Etcetera
  module BaseStrategy
    # This strategy implements the XDG Base Directories Specification
    # (https://specifications.freedesktop.org/basedir/latest/). It is the most
    # common on Linux, but is increasingly being adopted elsewhere.
    #
    # This initial example removes all the XDG environment variables to show the
    # strategy's use of the XDG default directories.
    #
    #   # Remove the environment variables that the strategy reads from.
    #   %w[
    #     XDG_CONFIG_HOME XDG_DATA_HOME XDG_CACHE_HOME XDG_STATE_HOME XDG_RUNTIME_DIR
    #   ].each { |name| ENV.delete(name) }
    #
    #   base_strategy = Etcetera::BaseStrategy::Xdg.new
    #   home_dir = Etcetera.home_dir
    #
    #   base_strategy.home_dir    # => home_dir
    #   base_strategy.config_dir  # => home_dir.join(".config")
    #   base_strategy.data_dir    # => home_dir.join(".local/share")
    #   base_strategy.cache_dir   # => home_dir.join(".cache")
    #   base_strategy.state_dir   # => home_dir.join(".local/state")
    #   base_strategy.runtime_dir # => nil
    #
    # This next example gives the environment variables values. (They must be
    # absolute paths, so use <tt>C:/foo</tt> and friends on Windows.)
    #
    #   ENV["XDG_CONFIG_HOME"] = "/foo"
    #   ENV["XDG_DATA_HOME"]   = "/bar"
    #   ENV["XDG_CACHE_HOME"]  = "/baz"
    #   ENV["XDG_STATE_HOME"]  = "/foobar"
    #   ENV["XDG_RUNTIME_DIR"] = "/qux"
    #
    #   base_strategy = Etcetera::BaseStrategy::Xdg.new
    #
    #   base_strategy.config_dir  # => Pathname.new("/foo")
    #   base_strategy.data_dir    # => Pathname.new("/bar")
    #   base_strategy.cache_dir   # => Pathname.new("/baz")
    #   base_strategy.state_dir   # => Pathname.new("/foobar")
    #   base_strategy.runtime_dir # => Pathname.new("/qux")
    #
    # The XDG spec requires that when the environment variables' values are not
    # absolute paths, their values should be ignored. This example exemplifies
    # this behaviour:
    #
    #   ENV["XDG_CONFIG_HOME"] = "foo"
    #   ENV["XDG_DATA_HOME"]   = "bar"
    #   ENV["XDG_CACHE_HOME"]  = "baz"
    #   ENV["XDG_STATE_HOME"]  = "foobar"
    #   ENV["XDG_RUNTIME_DIR"] = "qux"
    #
    #   base_strategy = Etcetera::BaseStrategy::Xdg.new
    #   home_dir = Etcetera.home_dir
    #
    #   # We still get the default values.
    #   base_strategy.config_dir  # => home_dir.join(".config")
    #   base_strategy.data_dir    # => home_dir.join(".local/share")
    #   base_strategy.cache_dir   # => home_dir.join(".cache")
    #   base_strategy.state_dir   # => home_dir.join(".local/state")
    #   base_strategy.runtime_dir # => nil
    class Xdg
      include Etcetera::BaseStrategy

      # Create a new Xdg base strategy.
      #
      # Raises Etcetera::HomeDirError if the home directory cannot be located.
      def initialize
        @home_dir = Etcetera.home_dir
      end

      attr_reader :home_dir

      def config_dir
        env_var_or_default("XDG_CONFIG_HOME", ".config")
      end

      def data_dir
        env_var_or_default("XDG_DATA_HOME", ".local/share")
      end

      def cache_dir
        env_var_or_default("XDG_CACHE_HOME", ".cache")
      end

      def state_dir
        env_var_or_default("XDG_STATE_HOME", ".local/state")
      end

      def runtime_dir
        env_var_or_none("XDG_RUNTIME_DIR")
      end

      private

      def env_var_or_none(env_var)
        value = ENV[env_var]
        return nil if value.nil?

        path = Pathname.new(value)
        # Return nil if the path obtained from the environment variable isn't
        # absolute.
        path.absolute? ? path : nil
      end

      def env_var_or_default(env_var, default)
        env_var_or_none(env_var) || home_dir.join(default)
      end
    end
  end
end
