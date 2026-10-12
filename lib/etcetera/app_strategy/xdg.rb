# frozen_string_literal: true

module Etcetera
  module AppStrategy
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
    #   app_strategy = Etcetera::AppStrategy::Xdg.new(Etcetera::AppStrategy::AppStrategyArgs.new(
    #     top_level_domain: "org",
    #     author: "Acme Corp",
    #     app_name: "Frobnicator Plus"
    #   ))
    #
    #   home_dir = Etcetera.home_dir
    #
    #   app_strategy.home_dir == home_dir # => true
    #   app_strategy.config_dir.relative_path_from(home_dir) # => #<Pathname:.config/frobnicator-plus>
    #   app_strategy.data_dir.relative_path_from(home_dir) # => #<Pathname:.local/share/frobnicator-plus>
    #   app_strategy.cache_dir.relative_path_from(home_dir) # => #<Pathname:.cache/frobnicator-plus>
    #   app_strategy.state_dir.relative_path_from(home_dir) # => #<Pathname:.local/state/frobnicator-plus>
    #   app_strategy.runtime_dir # => nil
    #
    # This next example gives the environment variables values:
    #
    #   require "etcetera"
    #
    #   # We need to conditionally set these to ensure that they are absolute paths both on Windows and other systems.
    #   windows = Gem.win_platform?
    #   config_path = windows ? "C:\\my_config_location\\" : "/my_config_location/"
    #   data_path = windows ? "C:\\my_data_location\\" : "/my_data_location/"
    #   cache_path = windows ? "C:\\my_cache_location\\" : "/my_cache_location/"
    #   state_path = windows ? "C:\\my_state_location\\" : "/my_state_location/"
    #   runtime_path = windows ? "C:\\my_runtime_location\\" : "/my_runtime_location/"
    #
    #   ENV["XDG_CONFIG_HOME"] = config_path
    #   ENV["XDG_DATA_HOME"] = data_path
    #   ENV["XDG_CACHE_HOME"] = cache_path
    #   ENV["XDG_STATE_HOME"] = state_path
    #   ENV["XDG_RUNTIME_DIR"] = runtime_path
    #
    #   app_strategy = Etcetera::AppStrategy::Xdg.new(Etcetera::AppStrategy::AppStrategyArgs.new(
    #     top_level_domain: "org",
    #     author: "Acme Corp",
    #     app_name: "Frobnicator Plus"
    #   ))
    #
    #   app_strategy.config_dir == Pathname.new("#{config_path}frobnicator-plus") # => true
    #   app_strategy.data_dir == Pathname.new("#{data_path}frobnicator-plus") # => true
    #   app_strategy.cache_dir == Pathname.new("#{cache_path}frobnicator-plus") # => true
    #   app_strategy.state_dir == Pathname.new("#{state_path}frobnicator-plus") # => true
    #   app_strategy.runtime_dir == Pathname.new("#{runtime_path}frobnicator-plus") # => true
    #
    # The XDG spec requires that when the environment variables’ values are not absolute paths, their values should be ignored. This example exemplifies this behaviour:
    #
    #   require "etcetera"
    #
    #   # Remove the environment variables that the strategy reads from.
    #   ENV["XDG_CONFIG_HOME"] = "relative_path/"
    #   ENV["XDG_DATA_HOME"] = "./another_one/"
    #   ENV["XDG_CACHE_HOME"] = "yet_another/"
    #   ENV["XDG_STATE_HOME"] = "./and_another"
    #   ENV["XDG_RUNTIME_DIR"] = "relative_path/"
    #
    #   app_strategy = Etcetera::AppStrategy::Xdg.new(Etcetera::AppStrategy::AppStrategyArgs.new(
    #     top_level_domain: "org",
    #     author: "Acme Corp",
    #     app_name: "Frobnicator Plus"
    #   ))
    #
    #   home_dir = Etcetera.home_dir
    #
    #   # We still get the default values.
    #   app_strategy.config_dir.relative_path_from(home_dir) # => #<Pathname:.config/frobnicator-plus>
    #   app_strategy.data_dir.relative_path_from(home_dir) # => #<Pathname:.local/share/frobnicator-plus>
    #   app_strategy.cache_dir.relative_path_from(home_dir) # => #<Pathname:.cache/frobnicator-plus>
    #   app_strategy.state_dir.relative_path_from(home_dir) # => #<Pathname:.local/state/frobnicator-plus>
    #   app_strategy.runtime_dir # => nil
    Xdg = Data.define(:base_strategy, :unixy_name) do
      include AppStrategy
      include FieldOrder

      class << self
        alias_method :from_fields, :new
        private :from_fields

        # Create a new Xdg AppStrategy
        def new(args) = from_fields(base_strategy: BaseStrategy::Xdg.new, unixy_name: args.unixy_name)
      end

      private :base_strategy, :unixy_name

      def home_dir = base_strategy.home_dir

      def config_dir = base_strategy.config_dir.join(unixy_name)

      def data_dir = base_strategy.data_dir.join(unixy_name)

      def cache_dir = base_strategy.cache_dir.join(unixy_name)

      def state_dir = base_strategy.state_dir.join(unixy_name)

      def runtime_dir = base_strategy.runtime_dir&.join(unixy_name)
    end
  end
end
