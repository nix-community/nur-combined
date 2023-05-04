{
  description = "Sane matrix chatbot";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.11";
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = { self, nixpkgs, flake-utils }:
    with flake-utils.lib; eachSystem allSystems (system:
    let
      pkgs = import nixpkgs {
        inherit system;
      };
    in rec {
      packages.mx-sanebot = pkgs.callPackage ./default.nix { };
      defaultPackage = packages.mx-sanebot;

      devShells.default = import ./shell.nix { inherit pkgs; };
    });
}
