{ lib, stdenv, fetchFromGitHub, cmake, git, quickcpplib, status-code, byte-lite, span-lite }:

stdenv.mkDerivation rec {
  pname = "ned14-outcome";
  version = "2.2.13";

  src = fetchFromGitHub {
    owner = "ned14";
    repo = "outcome";
    rev = "744da6b7536f2850df972ab01504e3c4d9530149";
    hash = "sha256-YNA9te9eWIAdclembi4WPEjHGpRh6TPZS8UsCDky+/M=";
  };

  nativeBuildInputs = [ cmake git byte-lite quickcpplib status-code span-lite ];

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
    mkdir -p include/outcome/experimental/status-code
    cp -r ${status-code}/* include/outcome/experimental/status-code/
  '';

  meta = with lib; {
    description = "C++14 library for reporting and handling function failures";
    homepage = "https://ned14.github.io/outcome/";
    license = licenses.asl20;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
