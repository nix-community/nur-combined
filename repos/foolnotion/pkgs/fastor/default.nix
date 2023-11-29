{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "Fastor";
  version = "0.6.4";

  src = fetchFromGitHub {
    owner = "romeric";
    repo = "Fastor";
    rev = "V${version}";
    hash = "sha256-L+mkuFxgeq0wGxem0NptfKv2qfo+8++0ULTk01oBV5I=";
  };

  nativeBuildInputs = [ cmake ];

  patches = [ ./pkgconfig-includedir.patch ];

  meta = with lib; {
    description = "A lightweight high performance tensor algebra framework for modern C++";
    homepage = "https://github.com/romeric/Fastor";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
