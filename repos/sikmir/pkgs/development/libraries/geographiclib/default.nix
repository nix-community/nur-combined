{ lib, stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "geographiclib";
  version = "1.51";

  src = fetchurl {
    url = "mirror://sourceforge/geographiclib/GeographicLib-${version}.tar.gz";
    sha256 = "046k49h52n2qxclqdzjmqj6pbvqsb28hn7lnsrdi1xbxc54hjdrl";
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
