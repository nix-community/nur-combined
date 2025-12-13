{ pkgs }:
let
  fenix = pkgs.fetchFromGitHub {
    owner = "nix-community";
    repo = "fenix";
    rev = "6399553b7a300c77e7f07342904eb696a5b6bf9d"; # Dec 2025
    hash = "sha256-C6tT7K1Lx6VsYw1BY5S3OavtapUvEnDQtmQB5DSgbCc=";
  };
  toolchain = (import fenix { inherit pkgs; }).minimal;
in
toolchain
