# https://github.com/NixOS/nixpkgs/blob/38cef0ba3b4c215cf1d4d03d137c66d948bdf1be/pkgs/applications/virtualization/looking-glass-client/default.nix
{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, SDL2
, SDL2_ttf
, spice-protocol
, fontconfig
, libX11
, freefont_ttf
, nettle
, libXau
, libXdmcp
, libXi
, libXext
, wayland
, libffi
, expat
, libbfd
, libXScrnSaver
, wayland-protocols
, libXinerama
}:
stdenv.mkDerivation rec {
  pname = "looking-glass-client";
  version = "5d5eb47598e74f7d398d4150267aa44d33eafd91";

  src = fetchFromGitHub {
    owner = "gnif";
    repo = "LookingGlass";
    rev = version;
    sha256 = "0x9zi1pkcva0lfn92gy9138vfakd8971snjxdqk383c1z6jyb9jh";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake pkg-config ];

  buildInputs = [
    SDL2
    SDL2_ttf
    spice-protocol
    fontconfig
    libX11
    freefont_ttf
    nettle
    libXau
    libXdmcp
    libXi
    libXext
    wayland
    libffi
    expat
    libbfd
    libXScrnSaver
    wayland-protocols
    libXinerama
  ];

  sourceRoot = "source/client";
  NIX_CFLAGS_COMPILE = "-mavx -Wno-uninitialized"; # Fix some sort of AVX compiler problem and avoid false-positive gcc warnings.

  meta = with lib; {
    description = "A KVM Frame Relay (KVMFR) implementation";
    longDescription = ''
      Looking Glass is an open source application that allows the use of a KVM
      (Kernel-based Virtual Machine) configured for VGA PCI Pass-through
      without an attached physical monitor, keyboard or mouse. This is the final
      step required to move away from dual booting with other operating systems
      for legacy programs that require high performance graphics.
    '';
    homepage = "https://looking-glass.io/";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ alexbakker ];
    platforms = [ "x86_64-linux" ];
  };
}
