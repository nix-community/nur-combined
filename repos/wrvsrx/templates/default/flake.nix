{
  description = "flake template";

  inputs = {
    nixpkgs.url = "github:wrvsrx/nixpkgs/patched-nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { inputs, ... }:
      {
        systems = [ "x86_64-linux" ];
        perSystem =
          { pkgs, ... }:
          rec {
            packages.default = pkgs.callPackage ./default.nix { };
            devShells.default = pkgs.mkShell { inputsFrom = [ packages.default ]; };
            formatter = pkgs.nixfmt-rfc-style;
          };
      }
    );
}
