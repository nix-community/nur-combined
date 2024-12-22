{
  stdenv,
  fetchurl,
  lib,
  pkgs,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "nezumi-p";
  version = "0.0.1";

  buildInputs = with pkgs; [
    pkg-config
    openssl
  ];

  nativeBuildInputs = with pkgs; [pkg-config];

  src = fetchFromGitHub {
    owner = "make-42";
    repo = "nezumi-p";
    rev = "ea623758cf235cc913d3785ebc6b97dfba08eba2";
    hash = "sha256-QIpTasTVTOT/a0GiWNOn57NgtyDU3d0io9Oq2x9wOXY=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  meta = with lib; {
    description = "A simple TUI for viewing Parisian public transport departure times.";
    homepage = "https://github.com/make-42/nezumi-p";
    license = licenses.gpl3;
    maintainers = [];
    platforms = platforms.linux;
  };
}
