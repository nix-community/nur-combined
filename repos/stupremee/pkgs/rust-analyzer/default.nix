{ system ? builtins.currentSystem, cargo2nix ? builtins.fetchGit {
  url = "https://github.com/cargo2nix/cargo2nix";
  rev = "4bbd3137ff1422ef3565748eae33efe6e2ffbf39";
}, nixpkgsMozilla ? builtins.fetchGit {
  url = "https://github.com/mozilla/nixpkgs-mozilla/";
  rev = "8c007b60731c07dd7a052cce508de3bb1ae849b4";
}, }:

let
  version = "2020-12-14";
  pkgs = import <nixpkgs> {
    inherit system;
    overlays = let
      rustOverlay = import "${nixpkgsMozilla}/rust-overlay.nix";
      cargo2nixOverlay = import "${cargo2nix}/overlay";
    in [ cargo2nixOverlay rustOverlay ];
  };

  rustPkgs = pkgs.rustBuilder.makePackageSet {
    packageFun = import ./Cargo.nix;
    rustChannel = pkgs.latest.rustChannels.stable;

    workspaceSrc = pkgs.fetchFromGitHub {
      owner = "rust-analyzer";
      repo = "rust-analyzer";
      rev = version;
      sha256 = "sha256-Onstk5zuQXVE+4pTAh0S5H9nnEPm6gnfbJ7fkM08Mq0=";
    };

    localPatterns = [
      "^(src|tests|crates|xtask|assets|templates)(/.*)?"
      "[^/]*\\.(rs|toml)$"
    ];
  };
in { rust-analyzer = (rustPkgs.workspace.rust-analyzer { }).bin; }
