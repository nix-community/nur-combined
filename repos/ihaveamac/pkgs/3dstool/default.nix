{ lib, openssl, iconv, curl, openldap, stdenv, cmake, clang, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "3dstool";
  version = "1.2.6";

  src = fetchFromGitHub {
    owner  = "dnasdw";
    repo   = "3dstool";
    rev    = "v${version}";
    sha256 = "sha256-YHSuayvFpJHr42ezn1P5OR4Gtp+M6nZL1+ko6hWFvR0=";
  };

  buildInputs = [ openssl iconv curl openldap ];
  nativeBuildInputs = [ cmake ];

  makeFlags = [ "CC=${stdenv.cc.targetPrefix}cc" "CXX=${stdenv.cc.targetPrefix}c++" ];
  cmakeFlags = [ "-DUSE_DEP=OFF" ];
  enableParallelBuilding = true;

  installPhase = "
    mkdir $out/bin -p
    cp ../bin/Release/3dstool $out/bin/
    cp ../bin/ignore_3dstool.txt $out/bin/
  ";

  meta = with lib; {
    description = "An all-in-one tool for extracting/creating 3ds roms.";
    homepage = "https://github.com/dnasdw/3dstool";
    license = licenses.mit;
    platforms = platforms.all;
    mainProgram = "3dstool";
  };
}
