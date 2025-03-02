{
  stdenv,
  lib,
  pkgs,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "ladybird";
  version = "2025-02-27";

  src = fetchFromGitHub {
    owner = "LadybirdBrowser";
    repo = "ladybird";
    rev = "b8af3fccf635a54e55577966c56dd5c08377c48f";
    hash = "sha256-zkLZFjRLK1cwR8BNDMqF3nbTTgPNGSRkXPKxF4DWD7I=";
  };

  buildInputs = with pkgs; [
    cmake
    ninja
  ];

  nativeBuildInputs = with pkgs; [
    pkg-config
  ];

  configurePhase = ''
    cmake -GNinja -B Build/release -S $src
  '';

  buildPhase = ''
    ninja -C Build/release -j$NIX_BUILD_CORES
  '';

  installPhase = ''
    cmake --build Build/release --target install
  '';

  meta = with lib; {
    homepage = "https://github.com/LadybirdBrowser/ladybird";
    description = "ladybird";
    platforms = platforms.linux;
  };
}
