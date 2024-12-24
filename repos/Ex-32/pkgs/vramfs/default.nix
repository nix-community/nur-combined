{
  lib,
  stdenv,
  fetchFromGitHub,
  fuse3,
  opencl-clhpp,
  ocl-icd,
  pkg-config,
}: let
  rev = "829b1f2c259da2eb63ed3d4ddef0eeddb08b99e4";
  hash = "sha256-i6My77lPO76ABupaJUIOHm7kyGqlfKQlzFas+Q2ooN8=";
in
  stdenv.mkDerivation rec {
    pname = "vramfs";
    version = builtins.substring 0 7 rev;

    src = fetchFromGitHub {
      owner = "Overv";
      repo = "vramfs";
      inherit rev hash;
    };

    buildInputs = [
      fuse3
      ocl-icd
    ];
    nativeBuildInputs = [
      opencl-clhpp
      pkg-config
    ];

    preBuild = ''
      substituteInPlace include/util.hpp --replace "<fuse.h>" "<fuse3/fuse.h>"
      substituteInPlace src/vramfs.cpp --replace "<fuse.h>" "<fuse3/fuse.h>"
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp "bin/${pname}" $out/bin/${pname}
    '';

    meta = {
      homepage = "https://github.com/Overv/vramfs";
      description = "VRAM based file system for Linux ";
      license = "none";
      platforms = lib.platforms.linux;
    };
  }
