{ lib, stdenv, fetchFromGitHub, cmake, git, quickcpplib, status-code }:

stdenv.mkDerivation rec {
  pname = "ned14-outcome";
  version = "2.2.8";

  src = fetchFromGitHub {
    owner = "ned14";
    repo = "outcome";
    rev = "5bcd0f32f28659a0eab62f1d643d878c2220788d";
    hash = "sha256-lEQGC49DMd3nTvGts0pr1Od1pIrG1tHbYwv25M8bW2s=";
  };

  nativeBuildInputs = [ cmake git quickcpplib status-code ];

  cmakeFlags = [
    "-DPROJECT_IS_DEPENDENCY=ON"
    "-DOUTCOME_BUNDLE_EMBEDDED_QUICKCPPLIB=OFF"
    "-Dquickcpplib_DIR=${quickcpplib}"
    "-DOUTCOME_BUNDLE_EMBEDDED_STATUS_CODE=OFF"
    "-Dstatus-code_DIR=${status-code}"
    "-DOUTCOME_ENABLE_DEPENDENCY_SMOKE_TEST=OFF"  # Leave this always on to test everything compiles
    "-DCMAKE_DISABLE_FIND_PACKAGE_Git=ON"
  ];

  preConfigure = ''
    substituteInPlace CMakeLists.txt --replace-fail find_dependency find_package
  '';

  meta = with lib; {
    description = "C++14 library for reporting and handling function failures";
    homepage = "https://ned14.github.io/outcome/";
    license = licenses.asl20;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
