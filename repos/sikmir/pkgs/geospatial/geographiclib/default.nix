{ lib, stdenv, fetchFromGitHub, cmake, doxygen }:

stdenv.mkDerivation rec {
  pname = "geographiclib";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "geographiclib";
    repo = "geographiclib";
    rev = "v${version}";
    hash = "sha256-7K4vI5vNSGPo2d9QNmasjJa4oMDfE8WTW6Guk2604Yg=";
  };

  nativeBuildInputs = [ cmake doxygen ];

  cmakeFlags = [
    "-DBUILD_DOCUMENTATION=ON"
  ];

  meta = with lib; {
    description = "GeographicLib offers a C++ interfaces to a small (but important!) set of geographic transformations";
    homepage = "https://geographiclib.sourceforge.io/";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
