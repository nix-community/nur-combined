{ pkgs, lib, stdenv, libdrm, dpkg, vulkan-loader, patchelf, fetchurl }:

let
  sources = import ./amdgpu-src.nix { inherit fetchurl; };
in
stdenv.mkDerivation rec {
  pname = "amdgpu-firmware";
  version = "5.4.6";

  src = fetchurl {
    url ="https://repo.radeon.com/amdgpu/5.4.6/ubuntu/pool/main/a/amdgpu-dkms/amdgpu-dkms-firmware_5.18.13.50406-1580598.22.04_all.deb";
    name = "amdgpu-firmware";
    sha256 ="7701fbb95900c2502aba03f4d3d29f1caaa935191bf21012ecff7ffa0f631696";
  };


  passthru = {
    vcn = stdenv.mkDerivation rec {
      pname = "amdgpu-firmware-vcn";
      version = sources.version;
      src = sources.bit64.amdgpu-dkms-firmware;
      inherit meta;
      inherit unpackPhase;
      inherit dontBuild;
      inherit dontFixup;
      inherit dontPatchELF;
      inherit nativeBuildInputs;
      inherit sourceRoot;


      installPhase = ''
        mkdir -p $out/lib/firmware/amdgpu
        mv lib/firmware/updates/amdgpu/vcn* $out/lib/firmware/amdgpu
      '';

    };
  };


  dontFixup = true;
  dontBuild = true;
  dontPatchELF = true;
  sourceRoot = ".";

  nativeBuildInputs = [
    dpkg
  ];
  unpackPhase = ''
    dpkg -x $src .
  '';

  installPhase = ''
    mkdir -p $out
    mv usr/src/amdgpu-5.18.13-1580598.22.04 $out/lib
  '';

  meta = with lib; {
    description = "AMDGPU Firmware, needed to be in sync for AMF to work";
    homepage = "https://www.amd.com";
    license = licenses.unfreeRedistributableFirmware;
    platforms = platforms.linux;
  };
}
