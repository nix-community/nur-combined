{ lib, stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "libgrapheme";
  version = "1";

  src = fetchurl {
    url = "https://dl.suckless.org/libgrapheme/libgrapheme-${version}.tar.gz";
    hash = "sha256-hiLfUVDOlB1cRmXQ4JodQsLCX2KKJ/SMoeZpV2Fi0PY=";
  };

  makeFlags = [ "AR:=$(AR)" "CC:=$(CC)" "RANLIB:=$(RANLIB)" ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "Unicode string library";
    homepage = "https://libs.suckless.org/libgrapheme/";
    license = licenses.isc;
    platforms = platforms.unix;
    maintainers = [ maintainers.sikmir ];
  };
}
