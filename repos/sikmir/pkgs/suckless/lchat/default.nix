{
  lib,
  stdenv,
  fetchFromGitHub,
  libgrapheme,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lchat";
  version = "1.0-unstable-2023-09-24";

  src = fetchFromGitHub {
    owner = "younix";
    repo = "lchat";
    rev = "d8006087f3056c9fb37ac4d2c59825fc0e05933a";
    hash = "sha256-KI9j/V3qml99HiFX+kHzeKkOpsqqDLoDhWzvM8ZggOU=";
  };

  buildInputs = [ libgrapheme ];

  makeFlags = [ "CC:=$(CC)" ];

  installFlags = [ "PREFIX=$(out)" ];

  preInstall = "mkdir -p $out/bin $out/man/man1";

  meta = {
    description = "line chat is a simple and elegant front end for ii-like chat programs";
    inherit (finalAttrs.src.meta) homepage;
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
