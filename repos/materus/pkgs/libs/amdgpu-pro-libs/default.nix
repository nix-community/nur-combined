{ pkgs, lib, xorg, stdenv, openssl, libdrm, zlib, dpkg, patchelf, fetchurl }:

let
  sources = import ./amdgpu-src.nix { inherit fetchurl; };
  suffix = if pkgs.stdenv.system == "x86_64-linux" then "64" else "32";
  amdbit = if pkgs.stdenv.system == "x86_64-linux" then "x86_64-linux-gnu" else "i386-linux-gnu";
in
stdenv.mkDerivation rec {
  pname = "amdgpu-pro-vulkan-${suffix}";
  version = sources.version;



  src = if stdenv.system == "x86_64-linux" then sources.bit64.vulkan-amdgpu-pro else sources.bit32.vulkan-amdgpu-pro;

  dontPatchELF = true;
  sourceRoot = ".";
  nativeBuildInputs = [
    dpkg
    patchelf
  ];
  buildInputs = [
    libdrm
    openssl
    stdenv.cc.cc.lib
    xorg.libX11
    xorg.libxcb
    xorg.libxshmfence
    zlib
  ];
  rpath = lib.makeLibraryPath buildInputs;

  unpackPhase = ''
    dpkg -x  $src .
  '';

  installPhase = ''
    mkdir -p $out/lib
    mkdir -p $out/share/vulkan/icd.d
    install -Dm644   opt/amdgpu-pro/etc/vulkan/icd.d/amd_icd${suffix}.json $out/share/vulkan/icd.d/amd_pro_icd${suffix}.json
    install -Dm755   opt/amdgpu-pro/lib/${amdbit}/amdvlk${suffix}.so $out/lib/amdvlkpro${suffix}.so
    sed -i "s#/opt/amdgpu-pro/lib/${amdbit}/amdvlk${suffix}.so#$out/lib/amdvlkpro${suffix}.so#" $out/share/vulkan/icd.d/amd_pro_icd${suffix}.json
    patchelf --set-rpath "$rpath" $out/lib/amdvlkpro${suffix}.so
  '';

  meta = with lib; {
    description = "AMD Proprietary Driver For Vulkan";
    homepage = "https://www.amd.com";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" "i686-linux" ];
  };
}
