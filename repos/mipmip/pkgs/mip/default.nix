{
  lib,
  fetchFromGitHub,
  crystal,
  pkg-config,
  cmake,
  fswatch,
  openssl,
  shards,
  nodejs,
  yarn,
  webkitgtk
}:

crystal.buildCrystalPackage rec {
  pname = "mip";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "mipmip";
    repo = "mip";
    rev = "0ec44d08ee4dacba063564f6a89bf1b7fcc635b1";
    sha256 = "sY9gypkDwT4+KGhCvu832G3h4YdGGRpd8eB37Zp1BUo=";
  };

  shardsFile = ./shards.nix;
  doCheck = false;

  nativeBuildInputs = [
    pkg-config
    cmake
    fswatch
    openssl
    crystal
    shards
    nodejs
    yarn
    webkitgtk
    cmake
  ];
#  buildInputs = [
#    fswatch
#    openssl
#    crystal
#    nodejs
#    yarn
#    webkitgtk
#    cmake
#  ];


  meta = with lib; {
    description = "Fast and simple markdown viewer";
    homepage = "https://github.com/mipmip/mip";
    license = licenses.mit;
  };
}
