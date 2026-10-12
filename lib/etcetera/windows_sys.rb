# frozen_string_literal: true

require "fiddle/import"

module Etcetera
  # The parts of the windows-sys crate that the crate uses, bound with Fiddle.
  # Only Windows loads this, as only Windows builds of the crate depend on it.
  #
  # Derived from windows-sys 0.61.2 (https://github.com/microsoft/windows-rs),
  # Copyright (c) Microsoft Corporation, used under the MIT License; see
  # LICENSE-WINDOWS-SYS.
  module WindowsSys
    extend Fiddle::Importer

    dlload "shell32.dll", "combase.dll"

    GUID = struct(["uint32_t data1", "uint16_t data2", "uint16_t data3", "uint8_t data4[8]"])

    def GUID.from_u128(uuid)
      malloc(Fiddle::RUBY_FREE).tap do |guid|
        guid.data1 = uuid >> 96
        guid.data2 = uuid >> 80 & 0xffff
        guid.data3 = uuid >> 64 & 0xffff
        guid.data4 = [uuid & 0xffff_ffff_ffff_ffff].pack("Q>").bytes
      end
    end

    S_OK = 0
    KF_FLAG_DONT_VERIFY = 16_384
    FOLDERID_LocalAppData = GUID.from_u128(0xf1b32785_6fba_4fcf_9d55_7b8e7f157091)
    FOLDERID_RoamingAppData = GUID.from_u128(0x3eb685db_65f9_4cf6_a03a_e3ef65729f3d)

    extern "int32_t SHGetKnownFolderPath(void* rfid, uint32_t dwflags, void* htoken, void* ppszpath)"
    extern "void CoTaskMemFree(void* pv)"
  end
  private_constant :WindowsSys
end
