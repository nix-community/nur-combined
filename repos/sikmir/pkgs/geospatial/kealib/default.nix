{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  hdf5,
}:

stdenv.mkDerivation rec {
  pname = "kealib";
  version = "1.5.3";

  src = fetchFromGitHub {
    owner = "ubarsc";
    repo = "kealib";
    rev = "kealib-${version}";
    hash = "sha256-s6sL8T1jRBmVCrFm00uCw9x6s43u9+GU3ihyMi7XSaQ=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ hdf5 ];

  meta = with lib; {
    description = "KEALib provides an implementation of the GDAL data model";
    homepage = "http://kealib.org/";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
