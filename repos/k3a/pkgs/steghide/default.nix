{ fetchurl
, lib
, stdenv
, gettext
, libmhash
, libjpeg
, libmcrypt
, zlib
, libtool
}:

stdenv.mkDerivation rec {
  pname = "steghide";
  version = "0.5.1";

  src = fetchurl {
    url = "mirror://sourceforge/${pname}/${pname}-${version}.tar.gz";
    sha256 = "78069b7cfe9d1f5348ae43f918f06f91d783c2b3ff25af021e6a312cf541b47b";
  };

  # from Fedora
  # https://src.fedoraproject.org/rpms/steghide/tree/rawhide
  patches = [ ./steghide-climits.patch ./steghide-0.5.1-gcc41.patch ./steghide-0.5.1-gcc70.patch ./steghide-0.5.1-perltests.patch ./steghide-0.5.1-gcc43.patch ./steghide-0.5.1-mhash.patch ];

  nativeBuildInputs = [ gettext libmhash libjpeg libmcrypt zlib libtool ];

  makeFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    homepage = "http://steghide.sourceforge.net/";
    description = "Embeds a message in a file by replacing some of the least significant bits";
    license = licenses.gpl2;
    maintainers = with maintainers; [ k3a ];
    platforms = platforms.unix;
  };
}
