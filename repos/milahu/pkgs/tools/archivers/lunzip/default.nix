{ lib
, stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  pname = "lunzip";
  version = "1.14";

  src = fetchurl {
    url = "http://download.savannah.gnu.org/releases/lzip/lunzip/lunzip-${version}.tar.gz";
    hash = "sha256-cKMMqIxTiwdKBKbV+hKlf46J/ry5FF0yLpUl82lOTLA=";
  };

  meta = with lib; {
    description = "unpack tar.lz archives compressed with lzip, a simplified form of lzma";
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
    homepage = "https://www.nongnu.org/lzip/lunzip.html";
    license = licenses.gpl2;
  };
}
