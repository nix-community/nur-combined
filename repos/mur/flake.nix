{
  description = "Myxa's (nix) User Repository";

  nixConfig = {
    extra-substituters = "https://mur.cachix.org";
    extra-trusted-public-keys = "mur.cachix.org-1:VncNRWnvAh+Pl71texI+mPOiwTB5267t029meC4HBC0=";
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    stable.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-parts.url = "github:hercules-ci/flake-parts";

    nix-github-actions = {
      url = "github:nix-community/nix-github-actions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, flake-parts, ... }:
    let
      overlays = final: prev: import ./overlay.nix final prev;
      lib = inputs.nixpkgs.lib;
    in
    flake-parts.lib.mkFlake { inherit inputs; } {

      flake =

        {
          overlays.default = overlays;
          githubActions =
            let
              filterPackages =
                pkgs:
                lib.filterAttrs (
                  name: pkg:
                  !(pkg.meta.broken or false) && (pkg.meta.license.free or true) && !(pkg.preferLocalBuild or false)
                ) pkgs;
              cacheablePkgs = {
                # aarch64-linux = filterPackages self.packages.aarch64-linux; # FIX:
                # x86_64-darwin = filterPackages self.packages.x86_64-darwin;
                x86_64-linux = filterPackages self.packages.x86_64-linux;
              };
            in
            inputs.nix-github-actions.lib.mkGithubMatrix { checks = cacheablePkgs; };
        };

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem =
        {
          config,
          self',
          inputs',
          pkgs,
          system,
          lib,
          ...
        }:
        let
          mur = import ./default.nix { inherit pkgs; };
          packages = lib.filterAttrs (_: v: lib.isDerivation v) mur;
          list-repo = pkgs.callPackage ./list-repo.nix { inherit pkgs packages overlays; }; # the binary is called "mur"
        in
        {
          legacyPackages = mur;

          packages = packages // {
            default = list-repo;
          };

          devShells.default = pkgs.mkShell {
            buildInputs = [
              # Package that creates env with all packages. Pretty self-explanatory.
              pkgs.buildEnv
              {
                name = "mur";
                paths = (builtins.attrValues packages) ++ [ list-repo ];
              }
            ];
          };
        };
    };
}
