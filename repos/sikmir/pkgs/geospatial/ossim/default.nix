{ lib, stdenv, fetchFromGitHub, cmake, geos, jsoncpp, libgeotiff, libjpeg, libtiff }:

stdenv.mkDerivation rec {
  pname = "ossim";
  version = "2.12.0";

  src = fetchFromGitHub {
    owner = "ossimlabs";
    repo = pname;
    rev = version;
    hash = "sha256-zmyzHEhf/JPBBP7yJyxyKHkJH5psRSl3h8ZcOJ7dr7o=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ geos jsoncpp libgeotiff libjpeg libtiff ];

  cmakeFlags = [
    "-DBUILD_OSSIM_APPS=OFF"
    "-DBUILD_OSSIM_TESTS=OFF"
  ];

  meta = with lib; {
    description = "Open Source Software Image Map library";
    homepage = "https://trac.osgeo.org/ossim";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
