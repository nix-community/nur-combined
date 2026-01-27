{
  description = "NUR package repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        nurPackages = import ./default.nix { inherit pkgs; };
      in
      {
        packages = nurPackages;

        # Make lazymake the default package
        packages.default = nurPackages.lazymake;

        # Development shell
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nix
            git
          ];
        };
      }
    );
}
