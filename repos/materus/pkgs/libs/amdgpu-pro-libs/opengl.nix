{ pkgs, lib, systemd, xorg, mesa, stdenv, expat, openssl, libdrm, zlib, wayland, dpkg, patchelf, fetchurl }:

let
  sources = import ./amdgpu-src.nix { inherit fetchurl; };
  suffix = if pkgs.stdenv.system == "x86_64-linux" then "64" else "32";
  amdbit = if pkgs.stdenv.system == "x86_64-linux" then "x86_64-linux-gnu" else "i386-linux-gnu";
in
stdenv.mkDerivation rec {
  pname = "amdgpu-pro-opengl-${suffix}";
  version = sources.version;


  src64 = [
    sources.bit64.libgl1-amdgpu-pro-oglp-dri
    sources.bit64.libgl1-amdgpu-pro-oglp-glx
    sources.bit64.libegl1-amdgpu-pro-oglp
    sources.bit64.libgles1-amdgpu-pro-oglp
    sources.bit64.libgles2-amdgpu-pro-oglp
  ];


  src32 = [
    sources.bit32.libgl1-amdgpu-pro-oglp-dri
    sources.bit32.libgl1-amdgpu-pro-oglp-glx
    sources.bit32.libegl1-amdgpu-pro-oglp
    sources.bit32.libgles1-amdgpu-pro-oglp
    sources.bit32.libgles2-amdgpu-pro-oglp
  ];

  src = if stdenv.system == "x86_64-linux" then src64 else src32;
  dontPatchELF = true;
  dontStrip = true;
  sourceRoot = ".";
  nativeBuildInputs = [
    dpkg
    patchelf
  ];
  buildInputs = [
    libdrm
    openssl
    expat
    stdenv.cc.cc.lib
    xorg.libX11
    xorg.libxcb
    xorg.libXext
    xorg.libXfixes
    xorg.libXxf86vm
    xorg.libxshmfence
    zlib
    wayland
    systemd
    mesa
  ];
  rpath = lib.makeLibraryPath buildInputs;
  unpackPhase = ''
    for file in $src; do dpkg -x $file .; done
  '';
  installPhase = ''
    mkdir $out
    mv opt/amdgpu/lib/${amdbit} $out/lib
    mv opt/amdgpu/share $out/share
    mv opt/amdgpu-pro/lib/${amdbit}/* $out/lib

    patchelf --set-rpath "$rpath" $out/lib/dri/amdgpu_dri.so
    for file in "$out/lib/*.so*"; do patchelf --set-rpath "$rpath" $file; done
  '';

  meta = with lib; {
    description = "AMD Proprietary Driver For OpenGL";
    homepage = "https://www.amd.com";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" "i686-linux" ];
  };
}
