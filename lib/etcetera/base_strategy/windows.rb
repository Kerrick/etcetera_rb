# frozen_string_literal: true

require "pathname"

require_relative "../base_strategy"

module Etcetera
  module BaseStrategy
    # This strategy follows Windows' conventions. It seems that all Windows GUI
    # apps, and some command-line ones follow this pattern. The specification is
    # available here
    # (https://docs.microsoft.com/en-us/windows/win32/shell/knownfolderid).
    #
    # This initial example removes the environment variables the strategy
    # reads:
    #
    # * (on Windows) the Known Folder API supplies the directories.
    # * (on non-Windows) the Windows default directories are used.
    #
    #   %w[APPDATA LOCALAPPDATA].each { |name| ENV.delete(name) }
    #
    #   base_strategy = Etcetera::BaseStrategy::Windows.new
    #   home_dir = Etcetera.home_dir
    #
    #   base_strategy.home_dir    # => home_dir
    #   base_strategy.config_dir  # => the RoamingAppData folder on Windows,
    #                             #    home_dir.join("AppData/Roaming") elsewhere
    #   base_strategy.data_dir    # => the same as config_dir
    #   base_strategy.cache_dir   # => the LocalAppData folder on Windows,
    #                             #    home_dir.join("AppData/Local") elsewhere
    #   base_strategy.state_dir   # => nil
    #   base_strategy.runtime_dir # => nil
    #
    # This next example gives the environment variables values:
    #
    #   ENV["APPDATA"]      = "C:/bar"
    #   ENV["LOCALAPPDATA"] = "C:/baz"
    #
    #   base_strategy = Etcetera::BaseStrategy::Windows.new
    #
    #   base_strategy.config_dir  # => Pathname.new("C:/bar")
    #   base_strategy.data_dir    # => Pathname.new("C:/bar")
    #   base_strategy.cache_dir   # => Pathname.new("C:/baz")
    #   base_strategy.state_dir   # => nil
    #   base_strategy.runtime_dir # => nil
    class Windows
      include Etcetera::BaseStrategy

      # Create a new Windows base strategy.
      #
      # Raises Etcetera::HomeDirError if the home directory cannot be located.
      def initialize
        @home_dir = Etcetera.home_dir
      end

      attr_reader :home_dir

      def config_dir
        data_dir
      end

      def data_dir
        dir_inner("APPDATA") || home_dir.join("AppData/Roaming")
      end

      def cache_dir
        dir_inner("LOCALAPPDATA") || home_dir.join("AppData/Local")
      end

      def state_dir
        nil
      end

      def runtime_dir
        nil
      end

      private

      def dir_inner(env)
        value = ENV[env]
        return Pathname.new(value) unless value.nil? || value.empty?

        dir_crt(env)
      end

      # Ref: https://github.com/rust-lang/cargo/blob/home-0.5.11/crates/home/src/windows.rs
      # We should keep this code in sync with the above.
      def dir_crt(env)
        folder_id = KnownFolders::FOLDER_IDS[env]
        return nil if folder_id.nil?

        path = KnownFolders.path_for(folder_id)
        path && Pathname.new(path)
      end

      # The Win32 Known Folder API, bound with Fiddle the first time it is
      # needed. Fiddle ships with every supported Ruby, so nothing extra has to
      # be installed, but it stopped being a default gem in Ruby 4.0 and
      # Bundler hides bundled gems the application has not asked for.
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

          # Returns the path of the given known folder, or nil if the folder is
          # unknown, this isn't Windows, Fiddle cannot be loaded, or the API
          # call fails.
          def path_for(folder_id)
            return nil unless windows_host?

            known_folder(pack_guid(folder_id))
          rescue LoadError
            # Fiddle is hidden from a Bundler-managed Ruby 4.0 process that has
            # not asked for it. Fall back to the default directories, as the
            # crate does when the API call itself fails.
            nil
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
    end
  end
end
