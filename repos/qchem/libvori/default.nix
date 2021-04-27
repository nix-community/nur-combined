{ stdenv, lib, fetchurl, cmake }:

stdenv.mkDerivation rec {
  pname = "libvori";
  version = "201229";

  nativeBuildInputs = [ cmake ];

  # Original server is misconfigured and messes up the file compression.
  src = fetchurl {
    url = "https://www.cp2k.org/static/downloads/${pname}-${version}.tar.gz";
    sha256 = "01ncvqikiabwn1w8995q7h48dzazs69bdl5zmqmdxy4l5hlzn2ns";
  };

  meta = with lib; {
    description = "Library for Voronoi intergration of electron densities";
    license = with licenses; [ lgpl3Only ];
    homepage = "https://brehm-research.de/libvori.php";
    platforms = platforms.unix;
  };
}
