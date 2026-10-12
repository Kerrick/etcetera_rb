# frozen_string_literal: true

module Etcetera
  module BaseStrategy # rubocop:disable Style/Documentation -- documented in base_strategy.rb
    if Gem.win_platform?
      require_relative "../windows_sys"

      # The C runtime function the crate declares in an `extern "C"` block.
      module CRT # :nodoc: all
        extend Fiddle::Importer

        dlload "ucrtbase.dll"
        extern "size_t wcslen(void* buf)"
      end
      private_constant :CRT
    end

    # This strategy follows Windows’ conventions. It seems that all \Windows GUI apps, and some command-line ones follow this pattern. The specification is available {here}[https://docs.microsoft.com/en-us/windows/win32/shell/knownfolderid].
    #
    # This initial example removes all the relevant environment variables to show the strategy’s use of the:
    # - (on \Windows) SHGetKnownFolderPath API.
    # - (on non-Windows) \Windows default directories.
    #
    #   require "etcetera"
    #
    #   # Remove the environment variables that the strategy reads from.
    #   ENV.delete("HOME")
    #   ENV.delete("APPDATA")
    #   ENV.delete("LOCALAPPDATA")
    #
    #   base_strategy = Etcetera::BaseStrategy::Windows.new
    #
    #   home_dir = Etcetera.home_dir
    #
    #   base_strategy.home_dir == home_dir # => true
    #   base_strategy.config_dir.relative_path_from(home_dir) # => #<Pathname:AppData/Roaming>
    #   base_strategy.data_dir.relative_path_from(home_dir) # => #<Pathname:AppData/Roaming>
    #   base_strategy.cache_dir.relative_path_from(home_dir) # => #<Pathname:AppData/Local>
    #   base_strategy.state_dir # => nil
    #   base_strategy.runtime_dir # => nil
    #
    # This next example gives the environment variables values:
    #
    #   require "etcetera"
    #
    #   windows = Gem.win_platform?
    #   home_path = windows ? "C:/foo/" : Etcetera.home_dir.to_s
    #   data_path = windows ? "C:\\bar\\" : "/bar/"
    #   cache_path = windows ? "C:\\baz\\" : "/baz/"
    #
    #   ENV["HOME"] = home_path
    #   ENV["APPDATA"] = data_path
    #   ENV["LOCALAPPDATA"] = cache_path
    #
    #   base_strategy = Etcetera::BaseStrategy::Windows.new
    #
    #   base_strategy.home_dir == Pathname.new(home_path) # => true
    #   base_strategy.config_dir == Pathname.new(data_path) # => true
    #   base_strategy.data_dir == Pathname.new(data_path) # => true
    #   base_strategy.cache_dir == Pathname.new(cache_path) # => true
    #   base_strategy.state_dir # => nil
    #   base_strategy.runtime_dir # => nil
    class Windows < Data.define(:home_dir)
      # Create a new \Windows \BaseStrategy
      def initialize(home_dir: Etcetera.home_dir) = super

      def config_dir = data_dir

      def data_dir = dir_inner("APPDATA") || home_dir.join("AppData").join("Roaming")

      def cache_dir = dir_inner("LOCALAPPDATA") || home_dir.join("AppData").join("Local")

      def state_dir = nil

      def runtime_dir = nil

      private

      def dir_inner(env)
        value = ENV.fetch(env, "")
        value.empty? ? dir_crt(env) : Pathname.new(value)
      end

      if Gem.win_platform?
        # Ref: https://github.com/rust-lang/cargo/blob/home-0.5.11/crates/home/src/windows.rs
        # We should keep this code in sync with the above.
        def dir_crt(env)
          folder_id = case env
                      when "APPDATA" then WindowsSys::FOLDERID_RoamingAppData
                      when "LOCALAPPDATA" then WindowsSys::FOLDERID_LocalAppData
                      else return nil
                      end

          path = Fiddle::Pointer.new(0)
          case WindowsSys.SHGetKnownFolderPath(folder_id.to_ptr, WindowsSys::KF_FLAG_DONT_VERIFY, nil, path.ref)
          when WindowsSys::S_OK
            path_slice = path[0, CRT.wcslen(path) * 2]
            s = path_slice.force_encoding(Encoding::UTF_16LE).encode(Encoding::UTF_8, invalid: :replace)
            WindowsSys.CoTaskMemFree(path)
            Pathname.new(s)
          else
            # Free any allocated memory even on failure. A null ptr is a no-op for `CoTaskMemFree`.
            WindowsSys.CoTaskMemFree(path)
            nil
          end
        end
      else
        def dir_crt(_env) = nil
      end
    end
  end
end
