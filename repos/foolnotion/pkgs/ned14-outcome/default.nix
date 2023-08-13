{ lib, stdenv, fetchFromGitHub, cmake, git, quickcpplib, status-code }:

stdenv.mkDerivation rec {
  pname = "ned14-outcome";
  version = "2.2.7";

  src = fetchFromGitHub {
    owner = "ned14";
    repo = "outcome";
    rev = "018620768577911c9b259275a5957525d55ad09a";
    hash = "sha256-Fh/REl8WEbIoRfUkw+pqJEAj05ceSJ6YGPthw0YckOM=";
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

  meta = with lib; {
    description = "C++14 library for reporting and handling function failures";
    homepage = "https://ned14.github.io/outcome/";
    license = licenses.asl20;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
