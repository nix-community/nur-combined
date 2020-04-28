{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "geographiclib";
  version = "1.50.1";

  src = fetchurl {
    url = "mirror://sourceforge/geographiclib/GeographicLib-${version}.tar.gz";
    sha256 = "1wc58csjhjp8jmcqxbaaikqczrjwwimmszlmfrgcrf38w04m0xni";
  };

  meta = with stdenv.lib; {
    description = "GeographicLib offers a C++ interfaces to a small (but important!) set of geographic transformations";
    homepage = "http://geographiclib.sourceforge.io/";
    license = licenses.mit;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.linux;
  };
}
