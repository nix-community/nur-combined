{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "u8strings";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "jwilk";
    repo = "u8strings";
    rev = "${finalAttrs.version}";
    hash = "sha256-wnv/qDn7Ke+dygRj+GFsRGtGDNsccYbXFe3gPSDAxAk=";
  };

  makeFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "strings(1) with UTF-8 support";
    homepage = "https://jwilk.net/software/u8strings";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };

})
