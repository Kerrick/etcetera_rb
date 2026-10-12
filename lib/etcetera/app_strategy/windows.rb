# frozen_string_literal: true

module Etcetera
  module AppStrategy
    # This strategy follows Windows’ conventions. It seems that all Windows GUI apps, and some command-line ones follow this pattern. The specification is available {here}[https://docs.microsoft.com/en-us/windows/win32/shell/knownfolderid].
    #
    # This initial example removes all the relevant environment variables to show the strategy’s use of the:
    # - (on Windows) SHGetKnownFolderPath API.
    # - (on non-Windows) Windows default directories.
    #
    #   require "etcetera"
    #
    #   # Remove the environment variables that the strategy reads from.
    #   ENV.delete("USERPROFILE")
    #   ENV.delete("APPDATA")
    #   ENV.delete("LOCALAPPDATA")
    #
    #   app_strategy = Etcetera::AppStrategy::Windows.new(Etcetera::AppStrategy::AppStrategyArgs.new(
    #     top_level_domain: "org",
    #     author: "Acme Corp",
    #     app_name: "Frobnicator Plus"
    #   ))
    #
    #   home_dir = Etcetera.home_dir
    #
    #   app_strategy.home_dir == home_dir # => true
    #   app_strategy.config_dir.relative_path_from(home_dir) # => #<Pathname:AppData/Roaming/Acme Corp/Frobnicator Plus/config>
    #   app_strategy.data_dir.relative_path_from(home_dir) # => #<Pathname:AppData/Roaming/Acme Corp/Frobnicator Plus/data>
    #   app_strategy.cache_dir.relative_path_from(home_dir) # => #<Pathname:AppData/Local/Acme Corp/Frobnicator Plus/cache>
    #   app_strategy.state_dir # => nil
    #   app_strategy.runtime_dir # => nil
    #
    # This next example gives the environment variables values:
    #
    #   require "etcetera"
    #
    #   windows = Gem.win_platform?
    #   home_path = windows ? "C:\\my_home_location\\" : Etcetera.home_dir.to_s
    #   data_path = windows ? "C:\\my_data_location\\" : "/my_data_location/"
    #   cache_path = windows ? "C:\\my_cache_location\\" : "/my_cache_location/"
    #
    #   ENV["USERPROFILE"] = home_path
    #   ENV["APPDATA"] = data_path
    #   ENV["LOCALAPPDATA"] = cache_path
    #
    #   app_strategy = Etcetera::AppStrategy::Windows.new(Etcetera::AppStrategy::AppStrategyArgs.new(
    #     top_level_domain: "org",
    #     author: "Acme Corp",
    #     app_name: "Frobnicator Plus"
    #   ))
    #
    #   app_strategy.home_dir == Pathname.new(home_path) # => true
    #   app_strategy.config_dir == Pathname.new("#{data_path}Acme Corp/Frobnicator Plus/config") # => true
    #   app_strategy.data_dir == Pathname.new("#{data_path}Acme Corp/Frobnicator Plus/data") # => true
    #   app_strategy.cache_dir == Pathname.new("#{cache_path}Acme Corp/Frobnicator Plus/cache") # => true
    #   app_strategy.state_dir # => nil
    #   app_strategy.runtime_dir # => nil
    class Windows < Data.define(:base_strategy, :author_app_name_path)
      include AppStrategy

      # Create a new Windows AppStrategy
      def self.new(args)
        super(
          base_strategy: BaseStrategy::Windows.new,
          author_app_name_path: Pathname.new(args.author).join(args.app_name)
        )
      end

      private :base_strategy, :author_app_name_path

      def home_dir = base_strategy.home_dir

      def config_dir = dir_method(:config_dir, "config")

      def data_dir = dir_method(:data_dir, "data")

      def cache_dir = dir_method(:cache_dir, "cache")

      def state_dir = nil

      def runtime_dir = nil

      private

      def dir_method(base_strategy_method, subfolder_name)
        base_strategy.public_send(base_strategy_method).join(author_app_name_path).join(subfolder_name)
      end
    end
  end
end
