{ lib, stdenv, fetchFromGitHub, cmake, git, quickcpplib, status-code, byte-lite, span-lite }:

stdenv.mkDerivation rec {
  pname = "ned14-outcome";
  version = "2.2.11";

  src = fetchFromGitHub {
    owner = "ned14";
    repo = "outcome";
    rev = "0a91b4ef5c0ee391172998586761f306ce82ae52";
    hash = "sha256-Shjw+2AJYbC25kOJEaeTmqZzd5nQhz0Fe+lxCmR9mcg=";
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

  patches = [ ./fix-status-code-include.patch ];

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
