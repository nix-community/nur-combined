{ pkgs, lib, stdenv, libdrm, dpkg, vulkan-loader, patchelf, fetchurl }:

let
  sources = import ./amdgpu-src.nix { inherit fetchurl; };
in
stdenv.mkDerivation rec {
  pname = "amdgpu-firmware";
  version = sources.version;

  src = sources.bit64.amdgpu-dkms-firmware;

  passthru = {
    vcn = stdenv.mkDerivation rec {
      pname = "amdgpu-firmware-vcn";
      inherit src;
      inherit version;
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
    mkdir -p $out/lib/firmware/
    mv lib/firmware/updates/amdgpu $out/lib/firmware/amdgpu
  '';

  meta = with lib; {
    description = "AMDGPU Firmware, needed to be in sync for AMF to work";
    homepage = "https://www.amd.com";
    license = licenses.unfreeRedistributableFirmware;
    platforms = platforms.linux;
  };
}
