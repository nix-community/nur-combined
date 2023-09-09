{ pkgs, lib, rustPlatform, fetchFromGitHub, pkg-config, openssl }:

rustPlatform.buildRustPackage rec {
  pname = "dman";
  version = "0.1.0";
  src = fetchFromGitHub {
    owner = "Adamekka";
    repo = "dotfile-manager";
    sha256 = "336ec8f81cf9e697f9fd48980cc7391ab4c69244=";
  };

  nativeBuildInputs = [
    pkg-config
  ];
  buildInputs = [
    openssl
  ];

  meta = with lib; {
    description = "Manage your dotfiles";
  };
}
