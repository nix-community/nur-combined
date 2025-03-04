
{ lib, stdenv, fetchFromGitHub, cmake, git, byte-lite, span-lite }:

stdenv.mkDerivation rec {
  pname = "ned14-quickcpplib";
  version = "0.1.0.0";

  src = fetchFromGitHub {
    owner = "ned14";
    repo = "quickcpplib";
    rev = "8d5ddc873686aeb036612a4200c3bd924150c23c";
    sha256 = "sha256-MFhx55o6KEchP2zSzZnQnkSIzsfn6shlJLa69172cro=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake git ];

  buildInputs = [ byte-lite span-lite ];

  cmakeFlags = [
    "-DQUICKCPPLIB_USE_SYSTEM_BYTE_LITE=1"
    "-DQUICKCPPLIB_USE_SYSTEM_SPAN_LITE=1"
  ];

  preConfigure = ''
    substituteInPlace cmakelib/quickcpplibConfig.override.cmake.in --replace-fail find_dependency find_package
  '';

  meta = with lib; {
    description = "Library to eliminate all the tedious hassle when making state-of-the-art C++ 14 - 23 libraries.";
    homepage = "https://github.com/ned14/quickcpplib";
    license = licenses.asl20;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
