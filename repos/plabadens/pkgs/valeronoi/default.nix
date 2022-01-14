{ stdenv
, lib
, fetchFromGitHub
, wrapQtAppsHook
, boost
, cgal_5
, cmake
, gmp
, mpfr
, qtbase
, qtimageformats
, qtsvg
}:

stdenv.mkDerivation {
  pname = "valeronoi";
  version = "0.1.6";

  src = fetchFromGitHub {
    owner = "ccoors";
    repo = "Valeronoi";
    rev = "0a0f850395c2092d10513be84f0b1daeaeaa6f2c";
    sha256 = "sha256-MNcOQkceCse2TvNiXyzc3T/i9TCTMeLPb6UWH8wsPOY=";
  };

  buildInputs = [ boost cgal_5 gmp mpfr qtbase qtimageformats qtsvg ];
  nativeBuildInputs = [ cmake wrapQtAppsHook ];

  checkPhase = "./valeronoi-tests";
  doCheck = true;

  meta = with lib; {
    description = "A WiFi mapping companion app for Valetudo";
    homepage = "https://github.com/ccoors/Valeronoi";
    license = licenses.mit;
    maintainers = with maintainers; [ plabadens ];
  };
}
