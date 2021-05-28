{ stdenv, lib, fetchurl, cmake } :

stdenv.mkDerivation rec {
  pname = "libvori";
  version = "210412";

  nativeBuildInputs = [ cmake ];

  # Original server is misconfigured and messes up the file compression.
  src = fetchurl {
    url = "https://www.cp2k.org/static/downloads/${pname}-${version}.tar.gz";
    sha256 = "1b4hpwibf3k7gl6n984l3wdi0zyl2fmpz84m9g2di4yhm6p8c61k";
  };

  meta = with lib; {
    description = "Library for Voronoi intergration of electron densities";
    homepage = "https://brehm-research.de/libvori.php";
    license = with licenses; [ lgpl3Only ];
    platforms = platforms.unix;
    maintainers = [ maintainers.sheepforce ];
  };
}
