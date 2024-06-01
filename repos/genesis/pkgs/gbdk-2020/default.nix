{ lib
, stdenv
, fetchgit
, autoconf
, gbdk-2020-sdcc
, doxygen
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gbdk-2020";
  version = "4.2.0+git20240531";

  src = fetchgit {
    "url" = "https://github.com/gbdk-2020/gbdk-2020";
    "rev" = "bfcbc153097bf0d6874568abff025713f812ed5e";
    "hash" = "sha256-t5kCDeSMTT++IWqtJ4Myh+KT/J4ZS5FNuVj4HJwRKaA=";
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
