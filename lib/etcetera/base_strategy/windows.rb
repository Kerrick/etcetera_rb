# frozen_string_literal: true

module Etcetera
  module BaseStrategy
    # The Win32 Known Folder API the Windows strategy calls through windows-sys
    # in the crate, bound with Fiddle the first time it is needed.
    module KnownFolders
      # FOLDERID_RoamingAppData and FOLDERID_LocalAppData, as defined by
      # windows-sys 0.61.
      FOLDER_IDS = {
        "APPDATA" => "3EB685DB-65F9-4CF6-A03A-E3EF65729F3D",
        "LOCALAPPDATA" => "F1B32785-6FBA-4FCF-9D55-7B8E7F157091"
      }.freeze

      # The folder is returned even if it does not exist on disk yet.
      KF_FLAG_DONT_VERIFY = 0x4000

      S_OK = 0

      # The UTF-16LE code unit that terminates the returned path.
      NULL_UNIT = "\x00\x00".b

      class << self
        def windows_host?
          WINDOWS_HOST
        end

        # Returns the path of the given known folder, or nil if this isn't
        # Windows or the API call fails.
        def path_for(folder_id)
          return nil unless windows_host?

          known_folder(pack_guid(folder_id))
        end

        private

        def known_folder(guid)
          require "fiddle"

          out = Fiddle::Pointer.malloc(Fiddle::SIZEOF_VOIDP, Fiddle::RUBY_FREE)
          result = shell32.SHGetKnownFolderPath(guid, KF_FLAG_DONT_VERIFY, nil, out)
          path_ptr = out.ptr
          path = wide_string(path_ptr) if result == S_OK && !path_ptr.null?
          # Free any allocated memory even on failure. A null ptr is a no-op
          # for CoTaskMemFree.
          co_task_mem_free(path_ptr)
          path
        end

        def shell32
          @shell32 ||= importer(
            "shell32.dll",
            "long SHGetKnownFolderPath(void* rfid, unsigned long flags, void* token, void* path)"
          )
        end

        def co_task_mem_free(pointer)
          task_mem_freeer.CoTaskMemFree(pointer)
        end

        # CoTaskMemFree moved from ole32.dll to combase.dll; try the modern
        # home first, as windows-sys 0.61 does.
        def task_mem_freeer
          @task_mem_freeer ||= importer("combase.dll", "void CoTaskMemFree(void* pv)")
        rescue Fiddle::DLError
          @task_mem_freeer = importer("ole32.dll", "void CoTaskMemFree(void* pv)")
        end

        def importer(dll, prototype)
          require "fiddle"
          require "fiddle/import"

          Module.new do
            extend Fiddle::Importer
            dlload dll
            extern prototype
          end
        end

        # A GUID is a u32, two u16s and eight u8s: the first three fields are
        # little-endian, the last eight bytes are big-endian.
        def pack_guid(folder_id)
          parts = folder_id.scan(/[0-9a-fA-F]+/).map { |hex| hex.to_i(16) }
          data1, data2, data3, data4_hi, data4_lo = parts

          [data1].pack("L<") +
            [data2, data3].pack("S<S<") +
            [data4_hi].pack("S>") +
            [data4_lo].pack("Q>")[2, 6]
        end

        # SHGetKnownFolderPath hands back a null-terminated UTF-16LE string.
        # Read it two bytes at a time so we never read past its end.
        def wide_string(pointer)
          units = String.new(encoding: Encoding::BINARY)
          offset = 0
          while (unit = pointer[offset, 2]) && unit != NULL_UNIT
            units << unit
            offset += 2
          end

          units.force_encoding(Encoding::UTF_16LE)
               .encode(Encoding::UTF_8, invalid: :replace, undef: :replace, replace: "\uFFFD")
        end
      end
    end
    private_constant :KnownFolders

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
    #   home_path = windows ? "C:\\foo\\" : Etcetera.home_dir.to_s
    #   data_path = windows ? "C:\\bar\\" : "/bar/"
    #   cache_path = windows ? "C:\\baz\\" : "/baz/"
    #
    #   ENV["USERPROFILE"] = home_path
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
    Windows = Data.define(:home_dir) do
      include BaseStrategy
      include FieldOrder

      # Create a new Windows BaseStrategy
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

      # Ref: https://github.com/rust-lang/cargo/blob/home-0.5.11/crates/home/src/windows.rs
      # We should keep this code in sync with the above.
      def dir_crt(env)
        folder_id = KnownFolders::FOLDER_IDS[env]
        return nil if folder_id.nil?

        path = KnownFolders.path_for(folder_id)
        path && Pathname.new(path)
      end
    end
  end
end
