
{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "quickcpplib";
  version = "0.1.0.0";

  src = fetchFromGitHub {
    owner = "ned14";
    repo = "quickcpplib";
    rev = "e948736ca111f004cfd6452943c8ef58a6415b61";
    sha256 = "sha256-lk3fmU7nN7X4aF9j628iSVKyaVvhREEW8AK7ngz/Jxk=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "Library to eliminate all the tedious hassle when making state-of-the-art C++ 14 - 23 libraries.";
    homepage = "https://github.com/ned14/quickcpplib";
    license = licenses.asl20;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
