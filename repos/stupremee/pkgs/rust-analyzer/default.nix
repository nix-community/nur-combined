{ pkgs }:

let
  version = "2020-12-14";

  rustPkgs = pkgs.rustBuilder.makePackageSet' {
    packageFun = import ./Cargo.nix;

    workspaceSrc = pkgs.fetchFromGitHub {
      owner = "rust-analyzer";
      repo = "rust-analyzer";
      rev = version;
      sha256 = "sha256-Onstk5zuQXVE+4pTAh0S5H9nnEPm6gnfbJ7fkM08Mq0=";
    };
  };
in { rust-analyzer = (rustPkgs.workspace.rust-analyzer { }).bin; }
