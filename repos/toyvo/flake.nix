{
  description = "My personal NUR repository";
  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://toyvo.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "toyvo.cachix.org-1:s++CG1te6YaS9mjICre0Ybbya2o/S9fZIyDNGiD4UXs="
    ];
  };
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    inputs@{
      flake-parts,
      treefmt-nix,
      self,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      imports = [
        flake-parts.flakeModules.easyOverlay
        treefmt-nix.flakeModule
      ];
      perSystem =
        {
          config,
          pkgs,
          lib,
          self',
          system,
          ...
        }:
        {
          treefmt = {
            programs = {
              nixfmt.enable = true;
              yamlfmt.enable = true;
              mdformat.enable = true;
            };
          };
          legacyPackages = self'.packages;
          packages = import ./. {
            inherit pkgs;
          };
          checks =
            let
              isCacheable =
                p:
                let
                  licenseFromMeta = p.meta.license or [ ];
                  licenseList = if builtins.isList licenseFromMeta then licenseFromMeta else [ licenseFromMeta ];
                in
                builtins.any (s: s == system) (p.meta.platforms or [ system ])
                && !(p.meta.broken or false)
                && !(p.preferLocalBuild or false)
                && builtins.all (license: license.free or true) licenseList;
            in
            lib.mapAttrs' (n: lib.nameValuePair "package-${n}") (
              lib.filterAttrs (n: v: isCacheable v) self'.packages
            )
            // lib.mapAttrs' (n: lib.nameValuePair "devShells-${n}") (
              lib.filterAttrs (n: v: isCacheable v) self'.devShells
            );
        };
    };
}
