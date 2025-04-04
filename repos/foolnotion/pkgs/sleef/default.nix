{ lib, stdenv, fetchFromGitHub, cmake, git, tlfloat, pkg-config
, enableShared ? !stdenv.hostPlatform.isStatic }:

stdenv.mkDerivation rec {
  pname = "sleef";
  version = "3.9.0";

  src = fetchFromGitHub {
    owner = "shibatch";
    repo = "sleef";
    rev = "${version}";
    sha256 = "sha256-0y/pRcxJmd+w9lbsVcjumjV5lQmpnmgfsMJPMCGpRm8=";
  };

  nativeBuildInputs = [ cmake git pkg-config ];

  buildInputs = [ tlfloat ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DBUILD_SHARED_LIBS=${if enableShared then "ON" else "OFF"}"
    "-DCMAKE_C_FLAGS_RELEASE=${if stdenv.hostPlatform.isx86_64 then "-march=x86-64-v3" else ""}"
    "-DSLEEF_DISABLE_OPENMP=ON"
    "-DSLEEF_ENABLE_TLFLOAT=ON"
    "-DSLEEF_BUILD_TESTS=OFF"
  ];

  meta = with lib; {
    description = "SIMD Library for Evaluating Elementary Functions";
    homepage = "https://sleef.org";
    license = licenses.boost;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}

