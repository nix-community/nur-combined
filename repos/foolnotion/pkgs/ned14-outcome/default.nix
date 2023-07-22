{ lib, stdenv, fetchFromGitHub, cmake, git, quickcpplib, status-code }:

stdenv.mkDerivation rec {
  pname = "ned14-outcome";
  version = "2.2.4";

  src = fetchFromGitHub {
    owner = "ned14";
    repo = "outcome";
    rev = "11a18c85ca7ae16af34ea309da5a0fe90024e3c3";
    sha256 = "sha256-JdMVJiW0FEn1UswrmAvoKv05xcvuuh3sAzXViAyQsGk=";
    #fetchSubmodules = true;
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
    "-DCXX_CONCEPTS_FLAGS="
  ];

  meta = with lib; {
    description = "C++14 library for reporting and handling function failures";
    homepage = "https://ned14.github.io/outcome/";
    license = licenses.asl20;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
