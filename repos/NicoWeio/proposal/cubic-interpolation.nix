{ lib, stdenv, cmake, fetchFromGitHub, boost, eigen }:

stdenv.mkDerivation {
  pname = "cubic-interpolation";
  version = "0.1.5-unstable-2025-10-07";

  src = fetchFromGitHub {
    owner = "tudo-astroparticlephysics";
    repo = "cubic_interpolation";
    rev = "86e90bc469027378e51d5d2ad1f9e6fd586d9115";
    hash = "sha256-V/vOu8zdzrFiL/2HEPk3fKdf/eriChJHBkv9hAuiDJ0=";
  };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [ boost eigen ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
    "-DBUILD_TESTING=OFF"
    "-DBUILD_EXAMPLE=OFF"
    "-DBUILD_DOCUMENTATION=OFF"
  ];

  meta = {
    description = "Interpolation library based on Boost and Eigen";
    homepage = "https://github.com/tudo-astroparticlephysics/cubic_interpolation";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
