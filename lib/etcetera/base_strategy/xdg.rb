# frozen_string_literal: true

module Etcetera
  module BaseStrategy
    # This strategy implements the {XDG Base Directories Specification}[https://specifications.freedesktop.org/basedir/latest/]. It is the most common on Linux, but is increasingly being adopted elsewhere.
    #
    # This initial example removes all the XDG environment variables to show the strategy’s use of the XDG default directories.
    #
    #   require "etcetera"
    #
    #   # Remove the environment variables that the strategy reads from.
    #   ENV.delete("XDG_CONFIG_HOME")
    #   ENV.delete("XDG_DATA_HOME")
    #   ENV.delete("XDG_CACHE_HOME")
    #   ENV.delete("XDG_STATE_HOME")
    #   ENV.delete("XDG_RUNTIME_DIR")
    #
    #   base_strategy = Etcetera::BaseStrategy::Xdg.new
    #
    #   home_dir = Etcetera.home_dir
    #
    #   base_strategy.home_dir == home_dir # => true
    #   base_strategy.config_dir.relative_path_from(home_dir) # => #<Pathname:.config>
    #   base_strategy.data_dir.relative_path_from(home_dir) # => #<Pathname:.local/share>
    #   base_strategy.cache_dir.relative_path_from(home_dir) # => #<Pathname:.cache>
    #   base_strategy.state_dir.relative_path_from(home_dir) # => #<Pathname:.local/state>
    #   base_strategy.runtime_dir # => nil
    #
    # This next example gives the environment variables values:
    #
    #   require "etcetera"
    #
    #   # We need to conditionally set these to ensure that they are absolute paths both on Windows and other systems.
    #   windows = Gem.win_platform?
    #   config_path = windows ? "C:\\foo\\" : "/foo/"
    #   data_path = windows ? "C:\\bar\\" : "/bar/"
    #   cache_path = windows ? "C:\\baz\\" : "/baz/"
    #   state_path = windows ? "C:\\foobar\\" : "/foobar/"
    #   runtime_path = windows ? "C:\\qux\\" : "/qux/"
    #
    #   ENV["XDG_CONFIG_HOME"] = config_path
    #   ENV["XDG_DATA_HOME"] = data_path
    #   ENV["XDG_CACHE_HOME"] = cache_path
    #   ENV["XDG_STATE_HOME"] = state_path
    #   ENV["XDG_RUNTIME_DIR"] = runtime_path
    #
    #   base_strategy = Etcetera::BaseStrategy::Xdg.new
    #
    #   base_strategy.config_dir == Pathname.new(config_path) # => true
    #   base_strategy.data_dir == Pathname.new(data_path) # => true
    #   base_strategy.cache_dir == Pathname.new(cache_path) # => true
    #   base_strategy.state_dir == Pathname.new(state_path) # => true
    #   base_strategy.runtime_dir == Pathname.new(runtime_path) # => true
    #
    # The XDG spec requires that when the environment variables’ values are not absolute paths, their values should be ignored. This example exemplifies this behaviour:
    #
    #   require "etcetera"
    #
    #   # Remove the environment variables that the strategy reads from.
    #   ENV["XDG_CONFIG_HOME"] = "foo/"
    #   ENV["XDG_DATA_HOME"] = "bar/"
    #   ENV["XDG_CACHE_HOME"] = "baz/"
    #   ENV["XDG_STATE_HOME"] = "foobar/"
    #   ENV["XDG_RUNTIME_DIR"] = "qux/"
    #
    #   base_strategy = Etcetera::BaseStrategy::Xdg.new
    #
    #   home_dir = Etcetera.home_dir
    #
    #   # We still get the default values.
    #   base_strategy.config_dir.relative_path_from(home_dir) # => #<Pathname:.config>
    #   base_strategy.data_dir.relative_path_from(home_dir) # => #<Pathname:.local/share>
    #   base_strategy.cache_dir.relative_path_from(home_dir) # => #<Pathname:.cache>
    #   base_strategy.state_dir.relative_path_from(home_dir) # => #<Pathname:.local/state>
    #   base_strategy.runtime_dir # => nil
    Xdg = Data.define(:home_dir) do
      include BaseStrategy
      include FieldOrder

      # Create a new Xdg BaseStrategy
      def initialize(home_dir: Etcetera.home_dir) = super

      def config_dir = env_var_or_default("XDG_CONFIG_HOME", ".config/")

      def data_dir = env_var_or_default("XDG_DATA_HOME", ".local/share/")

      def cache_dir = env_var_or_default("XDG_CACHE_HOME", ".cache/")

      def state_dir = env_var_or_default("XDG_STATE_HOME", ".local/state/")

      def runtime_dir = env_var_or_none("XDG_RUNTIME_DIR")

      private

      def env_var_or_none(env_var)
        path = ENV[env_var]&.then { Pathname.new(it) }

        # Return nil if the path obtained from the environment variable isn’t absolute.
        path if path&.absolute?
      end

      def env_var_or_default(env_var, default) = env_var_or_none(env_var) || home_dir.join(default)
    end
  end
end
