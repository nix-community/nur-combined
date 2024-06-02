{ lib
, stdenv
, fetchgit
, autoconf
, gbdk-2020-sdcc
, doxygen
, excludePorts ? [
    "nes"
  ]
}:

assert lib.subtractLists [
  "gb"
  "ap"
  "duck"
  "gg"
  "sms"
  "msxdos"
  "nes"
]
  excludePorts == [ ];

stdenv.mkDerivation (finalAttrs: {
  pname = "gbdk-2020";
  version = "4.2.0+git20240531";

  src = fetchgit {
    "url" = "https://github.com/gbdk-2020/gbdk-2020";
    "rev" = "4fb514b4d0d28ca093836e12278f9044c21864a0";
    "hash" = "sha256-GBY3FJkQXoB2Uf9b6Eh4Qxn69+Opd3Bn6NJ1YnRzKq0=";
  };

  outputs = [ "out" ];

  enableParallelBuilding = true;

  nativeBuildInputs = [
    autoconf
  ];

  buildInputs = [ gbdk-2020-sdcc ];

  makeFlags = [
    "TARGETDIR=${builtins.placeholder "out"}"
    "SDCCDIR=${gbdk-2020-sdcc}"
    "gbdk-build"
  ];

  meta = {
    homepage = "https://gbdk-2020.github.io/gbdk-2020/";
    description = "cross-platform development kit";
    longDescription = ''
      GBDK is a cross-platform development kit for sm83, z80 and 6502 
      based gaming consoles. It includes libraries, toolchain utilities 
      and the SDCC C compiler suite.
    '';
    platforms = lib.platforms.all;
  };
})
