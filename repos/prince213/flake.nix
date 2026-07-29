{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default/future-26.11";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      flake-parts,
      systems,
      treefmt-nix,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ treefmt-nix.flakeModule ];
      systems = import systems;
      flake = {
        overlays.default = import ./pkgs/top-level/all-packages.nix;
      };
      perSystem =
        {
          system,
          lib,
          pkgs,
          ...
        }:
        let
          overlay = self.overlays.default;
        in
        {
          packages = lib.filterAttrs (_: lib.meta.availableOn { inherit system; }) (
            lib.removeAttrs (overlay (pkgs.extend overlay) pkgs) [
              "linuxKernel"
              "pythonPackagesExtensions"
            ]
          );
          legacyPackages = pkgs.extend overlay;

          treefmt = {
            projectRootFile = "flake.nix";
            programs.nixfmt.enable = true;
          };
        };
    };
}
