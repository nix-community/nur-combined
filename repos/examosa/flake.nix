{
  description = "My personal NUR repository";

  inputs = {
    flake-compat.url = "github:NixOS/flake-compat";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";
    systems.url = "github:nix-systems/default";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://examosa.cachix.org"
      "https://nix-community.cachix.org"
    ];

    extra-trusted-public-keys = [
      "examosa.cachix.org-1:ygyyHGQtFnPwyk31fWUOvGq0Z4J+cPCCMcwBFEJT8GA="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  outputs = inputs @ {
    flake-parts,
    systems,
    self,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = import systems;

      imports = [inputs.treefmt-nix.flakeModule];

      perSystem = {
        config,
        lib,
        pkgs,
        ...
      }: let
        legacyPackages = import self {inherit pkgs;};
      in {
        checks.format = config.treefmt.build.check self;
        inherit legacyPackages;
        packages = lib.filterAttrs (_: lib.isDerivation) legacyPackages;

        treefmt = {
          projectRootFile = "flake.nix";
          programs.alejandra.enable = true;
        };
      };

      flake.overlays = import ./overlays;
    };
}
