{
  description = "";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;
  };

  outputs = (inputs@{ self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        buildInputs = with pkgs; [ ];
        nativeBuildInputs = with pkgs; [ ];
      in
      rec {
        devShell = pkgs.mkShell {
          inherit buildInputs nativeBuildInputs;
        };
      }
    )
  );
}
