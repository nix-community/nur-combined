{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "scroll";
  version = "0.1";

  src = fetchurl {
    url = "https://dl.suckless.org/tools/scroll-${finalAttrs.version}.tar.gz";
    hash = "sha256-nrLVnOat9gEAvSFxsNIx3bR+J0sp3tAiVpYKEezO7tY=";
  };

  makeFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Scrollbackbuffer program for st";
    homepage = "https://tools.suckless.org/scroll/";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
