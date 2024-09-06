{
  lib,
  stdenv,
  fetchFromGitHub,
  libgrapheme,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lchat";
  version = "1.0-unstable-2024-07-14";

  src = fetchFromGitHub {
    owner = "younix";
    repo = "lchat";
    rev = "0c43215d0b1981d1689105122da02b7e994e250a";
    hash = "sha256-MfwEXwTmSqFHSfVrqdlaLbCkU4lgsGeXBTCAhvQZCUo=";
  };

  buildInputs = [ libgrapheme ];

  makeFlags = [ "CC:=$(CC)" ];

  installFlags = [ "PREFIX=$(out)" ];

  preInstall = "mkdir -p $out/bin $out/man/man1";

  meta = {
    description = "line chat is a simple and elegant front end for ii-like chat programs";
    homepage = "https://github.com/younix/lchat";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
