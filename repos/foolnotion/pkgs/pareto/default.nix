{ lib, stdenv, fetchFromGitHub, cmake, git, pythonPackages }:

stdenv.mkDerivation rec {
  pname = "pareto";
  version = "1.2.0";

  src = fetchFromGitHub {
    repo = "pareto";
    owner = "alandefreitas";
    rev = "c133aa6c3be682d12e6fcbfa26a80da28ebb8b70";
    sha256 = "sha256-tkAlvg0E0e6RIJ4WCL30mfXq8hPtZcwrh90ryIBwODQ=";
  };

  nativeBuildInputs = [ git cmake ];

  #buildInputs = [ pythonPackages.pybind11 ];

  preConfigure = ''
      cmakeFlags="$cmakeFlags -DCMAKE_INSTALL_PREFIX=$out -DCMAKE_FIND_USE_SYSTEM_PACKAGE_REGISTRY=ON -DBUILD_PYTHON_BINDING=OFF -DBUILD_EXAMPLES=OFF -DBUILD_TESTS=OFF"
  '';

  doCheck = false;

  meta = with lib; {
    description = "Spatial Containers, Pareto Fronts, and Pareto Archives";
    homepage = "https://alandefreitas.github.io/pareto/";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
