{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "Fastor";
  version = "0.6.4";

  src = fetchFromGitHub {
    owner = "romeric";
    repo = "Fastor";
    rev = "652972f981f51f503b4f66f7190d5bd69b980dee";
    hash = "sha256-AEmuXoPCOXURGD1ITO77G9pioZ7qZm0QT/4JZM41/s0=";
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
