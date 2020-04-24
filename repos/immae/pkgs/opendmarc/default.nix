{ stdenv, fetchurl, pkgconfig, libbsd, openssl, libmilter , perl, makeWrapper, libspf2 }:

stdenv.mkDerivation rec {
  name = "opendmarc-${version}";
  version = "1.3.2";

  src = fetchurl {
    url = "mirror://sourceforge/opendmarc/files/${name}.tar.gz";
    sha256 = "1yrggj8yq0915y2i34gfz2xpl1w2lgb1vggp67rwspgzm40lng11";
  };

  configureFlags= [
    "--with-spf"
    "--with-spf2-include=${libspf2}/include/spf2"
    "--with-spf2-lib=${libspf2}/lib/"
    "--with-milter=${libmilter}"
  ];

  buildInputs = [ libspf2 libbsd openssl libmilter perl ];

  meta = with stdenv.lib; {
    description = "Free open source software implementation of the DMARC specification";
    homepage = http://www.trusteddomain.org/opendmarc/;
    platforms = platforms.unix;
  };
}
