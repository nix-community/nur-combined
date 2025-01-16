{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "blind";
  version = "1.1";

  src = fetchurl {
    url = "https://dl.suckless.org/tools/blind-${finalAttrs.version}.tar.gz";
    hash = "sha256-JPkDzLXhGNdfONOuDYX+2Ql0n5eL/0f/aXPuG/3fzFo=";
  };

  installFlags = [ "PREFIX=$(out)" ];

  env.NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types";

  meta = {
    description = "Collection of command line video editing utilities";
    homepage = "https://tools.suckless.org/blind/";
    license = lib.licenses.isc;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.sikmir ];
    skip.ci = stdenv.isDarwin;
  };
})
