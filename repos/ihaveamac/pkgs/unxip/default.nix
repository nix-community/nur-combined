{
  stdenv,
  lib,
  fetchFromGitHub,
  swiftPackages,
  xz,
  zlib,
}:

swiftPackages.swift.stdenv.mkDerivation rec {
  pname = "unxip";
  version = "3.0";

  src = fetchFromGitHub {
    owner = "saagarjha";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-GpiJ4F+VMrVSgNACMuCTixWd32eco3eaSKZotP4INT8=";
  };

  buildInputs = [
    swiftPackages.swift
    swiftPackages.Foundation
    xz
    zlib
  ];

  buildPhase = ''
    # the Makefile as it is just calls swiftc
    # it also won't run as-is because I need to add "-I Sources"
    # so removing it will prevent future stages from being confused
    rm Makefile

    swiftc -I Sources -O -whole-module-optimization -parse-as-library unxip.swift
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp unxip $out/bin/unxip
  '';

  meta = with lib; {
    description = "A fast Xcode unarchiver";
    homepage = "https://github.com/saagarjha/unxip";
    license = licenses.lgpl3;
    platforms = platforms.unix;
    # funny that this is broken on macOS, but there's build errors i don't know how to fix yet
    broken = stdenv.isDarwin;
    mainProgram = "unxip";
  };
}
