{ stdenv, lib, fetchFromGitHub, cmake, gfortran, python3 } :

let
  python = python3.withPackages (p: with p; [ pybind11 ]);

in stdenv.mkDerivation rec {
  pname = "xcfun";
  version = "2.1.1";

  nativeBuildInputs = [
    cmake
    gfortran
  ];

  propagatedBuildInputs = [ python ];

  cmakeFlags = [ "-DXCFUN_MAX_ORDER=3" ];

  enableParallelBuilding = true;

  src = fetchFromGitHub  {
    owner = "dftlibs";
    repo = pname;
    rev = "v${version}";
    sha256= "1bj70cnhbh6ziy02x988wwl7cbwaq17ld7qwhswqkgnnx8rpgxid";
  };

  meta = with lib; {
    description = "A library of exchange-correlation functionals with arbitrary-order derivatives.";
    homepage = "https://github.com/dftlibs/xcfun";
    license = licenses.mpl20;
    platforms = platforms.linux;
  };
}
