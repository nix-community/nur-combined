{ lib, stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "blind";
  version = "1.1";

  src = fetchurl {
    url = "https://dl.suckless.org/tools/blind-${version}.tar.gz";
    hash = "sha256-JPkDzLXhGNdfONOuDYX+2Ql0n5eL/0f/aXPuG/3fzFo=";
  };

  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "Collection of command line video editing utilities";
    homepage = "https://tools.suckless.org/blind/";
    license = licenses.isc;
    platforms = platforms.linux;
    maintainers = [ maintainers.sikmir ];
    skip.ci = stdenv.isDarwin;
  };
}
