{ pkgs, lib, stdenv, libdrm, dpkg, vulkan-loader, patchelf, fetchurl }:

let
  sources = import ./amdgpu-src.nix { inherit fetchurl; };
in
stdenv.mkDerivation rec {
  pname = "amf-amdgpu-pro";
  version = sources.version;



  src = [
    sources.bit64.libamdenc-amdgpu-pro
    sources.bit64.amf-amdgpu-pro
  ];


  dontPatchELF = true;
  sourceRoot = ".";
  nativeBuildInputs = [
    dpkg
    patchelf
  ];
  buildInputs = [
    vulkan-loader
    stdenv.cc.cc.lib
    libdrm
  ];
  rpath = lib.makeLibraryPath buildInputs;
  unpackPhase = ''
    for file in $src; do dpkg -x $file .; done
  '';

  installPhase = ''
    mkdir -p $out
    mv opt/amdgpu-pro/lib/x86_64-linux-gnu $out/lib
    patchelf --set-rpath "$rpath" $out/lib/libamdenc64.so
    patchelf --set-rpath "$rpath" $out/lib/libamfrt64.so
  '';

  meta = with lib; {
    description = "AMD Advanced Multimedia Framework";
    homepage = "https://www.amd.com";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}
