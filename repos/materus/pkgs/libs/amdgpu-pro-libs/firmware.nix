{ pkgs, lib, stdenv, libdrm, dpkg, vulkan-loader, patchelf, fetchurl }:

let
  sources = import ./amdgpu-src.nix { inherit fetchurl; };
in
stdenv.mkDerivation rec {
  pname = "amdgpu-firmware";
  version = sources.version;



  src = sources.bit64.amdgpu-dkms-firmware;



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
