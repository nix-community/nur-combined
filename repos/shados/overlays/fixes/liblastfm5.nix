{ stdenv, fetchFromGitHub, pkgconfig, cmake, which, qtbase, libsamplerate
, fftwSinglePrec }:

stdenv.mkDerivation rec {
  name = "${pname}-${version}";
  pname = "liblastfm-qt5";
  version = "unstable-2019-08-23";

  src = fetchFromGitHub {
    owner = "lastfm"; repo = "liblastfm";
    rev = "2ce2bfe1879227af8ffafddb82b218faff813db9";
    sha256 = "1crih9xxf3rb109aqw12bjqv47z28lvlk2dpvyym5shf82nz6yd0";
  };

  prefixKey = "--prefix ";
  cmakeFlags = [
    # Couldn't get it to build with tests enabled, it fails to find QtTest
    # headers, which should be present in qtbase...
    "-DBUILD_TESTS=OFF"
  ];
  buildInputs = [
    qtbase
  ];
  propagatedBuildInputs = [
    libsamplerate
    fftwSinglePrec
  ];
  nativeBuildInputs = [ pkgconfig which cmake qtbase ];

  meta = with stdenv.lib; {
    homepage = "https://github.com/lastfm/liblastfm";
    description = "Official LastFM library";
    maintainers =  [ maintainers.arobyn ];
    license = licenses.gpl3;
  };
}
