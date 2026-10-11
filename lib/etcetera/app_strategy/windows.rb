# frozen_string_literal: true

require "pathname"

require_relative "../app_strategy"
require_relative "../base_strategy/windows"

module Etcetera
  module AppStrategy
    # This strategy follows Windows' conventions. It seems that all Windows GUI
    # apps, and some command-line ones follow this pattern. The specification is
    # available here
    # (https://docs.microsoft.com/en-us/windows/win32/shell/knownfolderid).
    #
    # This initial example removes the environment variables the strategy
    # reads:
    #
    # * (on Windows) the Known Folder API supplies the parent directories.
    # * (on non-Windows) the Windows default directories are used.
    #
    #   %w[APPDATA LOCALAPPDATA].each { |name| ENV.delete(name) }
    #
    #   args = Etcetera::AppStrategy::AppStrategyArgs.new(
    #     top_level_domain: "org",
    #     author: "Acme Corp",
    #     app_name: "Frobnicator Plus"
    #   )
    #   app_strategy = Etcetera::AppStrategy::Windows.new(args)
    #   home_dir = Etcetera.home_dir
    #
    #   app_strategy.home_dir    # => home_dir
    #   app_strategy.config_dir  # => RoamingAppData/Acme Corp/Frobnicator Plus/config
    #                            #    on Windows, home_dir.join(
    #                            #    "AppData/Roaming/Acme Corp/Frobnicator Plus/config")
    #                            #    elsewhere
    #   app_strategy.data_dir    # => the same, with "data" instead of "config"
    #   app_strategy.cache_dir   # => LocalAppData/Acme Corp/Frobnicator Plus/cache
    #                            #    on Windows, home_dir.join(
    #                            #    "AppData/Local/Acme Corp/Frobnicator Plus/cache")
    #                            #    elsewhere
    #   app_strategy.state_dir   # => nil
    #   app_strategy.runtime_dir # => nil
    #
    # This next example gives the environment variables values:
    #
    #   ENV["APPDATA"]      = "C:/my_data_location"
    #   ENV["LOCALAPPDATA"] = "C:/my_cache_location"
    #
    #   args = Etcetera::AppStrategy::AppStrategyArgs.new(
    #     top_level_domain: "org",
    #     author: "Acme Corp",
    #     app_name: "Frobnicator Plus"
    #   )
    #   app_strategy = Etcetera::AppStrategy::Windows.new(args)
    #
    #   app_strategy.config_dir # => Pathname.new("C:/my_data_location/Acme Corp/Frobnicator Plus/config")
    #   app_strategy.data_dir   # => Pathname.new("C:/my_data_location/Acme Corp/Frobnicator Plus/data")
    #   app_strategy.cache_dir  # => Pathname.new("C:/my_cache_location/Acme Corp/Frobnicator Plus/cache")
    #   app_strategy.state_dir  # => nil
    #   app_strategy.runtime_dir # => nil
    class Windows
      include Etcetera::AppStrategy

      # Create a new Windows app strategy.
      #
      # Raises Etcetera::HomeDirError if the home directory cannot be located.
      def initialize(args)
        @base_strategy = Etcetera::BaseStrategy::Windows.new
        @author_app_name_path = Pathname.new(args.author).join(args.app_name)
      end

      def home_dir
        @base_strategy.home_dir
      end

      def config_dir
        @base_strategy.config_dir.join(@author_app_name_path).join("config")
      end

      def data_dir
        @base_strategy.data_dir.join(@author_app_name_path).join("data")
      end

      def cache_dir
        @base_strategy.cache_dir.join(@author_app_name_path).join("cache")
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
