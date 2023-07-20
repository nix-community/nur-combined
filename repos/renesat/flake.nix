{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = import ./overlays.nix;
      };
    in rec {
      packages = import ./default.nix {
        inherit pkgs;
        inherit system;
      };
      devShells = {
        default = pkgs.mkShell rec {
          buildInputs = with pkgs; [
            python3
            python3Packages.pip
            packages.qpsolvers
          ];
        };
      };
    });
}
