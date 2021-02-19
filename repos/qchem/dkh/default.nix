{ lib, stdenv, gfortran, fetchFromGitHub, cmake }:
stdenv.mkDerivation rec {
  pname = "dkh";
  version = "1.2";

  nativeBuildInputs = [
    gfortran
    cmake
  ];

  src = fetchFromGitHub  {
    owner = "psi4";
    repo = pname;
    rev = "v${version}";
    sha256= "1wb4qmb9f8rnrwnnw1gdhzx1fmhy628bxfrg56khxy3j5ljxkhck";
  };

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=ON"
  ];

  hardeningDisable = [
    "format"
  ];

  meta = with lib; {
    description = "Arbitrary-​order scalar-​relativistic Douglas-​Kroll-Hess module";
    license = licenses.lgpl3;
    homepage = "https://github.com/psi4/dkh";
    platforms = platforms.unix;
  };
}
