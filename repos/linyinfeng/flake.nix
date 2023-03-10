{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    # flake modules
    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
    devshell.inputs.flake-utils.follows = "flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    # libs
    flake-utils.url = "github:numtide/flake-utils";

    # main nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # extra nixpkgs for checks
    nixos-stable.url = "github:nixos/nixpkgs/nixos-22.11";
  };

  outputs = inputs @ { flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; }
      {
        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];
        imports = [
          inputs.flake-parts.flakeModules.easyOverlay
          inputs.devshell.flakeModule
          inputs.treefmt-nix.flakeModule

          ./flake
        ];
      };
}
