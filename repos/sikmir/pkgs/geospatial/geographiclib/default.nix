{ lib, stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "geographiclib";
  version = "2.1";

  src = fetchurl {
    url = "mirror://sourceforge/geographiclib/GeographicLib-${version}.tar.gz";
    hash = "sha256-ekvbz+dseEiWDxd7WXGH4Wq9MBQNoGf/UiHO6QDPwCk=";
  };

  meta = with lib; {
    description = "GeographicLib offers a C++ interfaces to a small (but important!) set of geographic transformations";
    homepage = "http://geographiclib.sourceforge.io/";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}
