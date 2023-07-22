
{ lib, stdenv, fetchFromGitHub, cmake, git }:

stdenv.mkDerivation rec {
  pname = "ned14-status-code";
  version = "0.1.0.0";

  src = fetchFromGitHub {
    owner = "ned14";
    repo = "status-code";
    rev = "b9825d432856ad350096951374f9988735f36de8";
    sha256 = "sha256-J6LQWTpv5Ds9qMkyhNRK8BN7WyY1dyCQpbANfNim9tM=";
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
