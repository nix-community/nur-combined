{
  description = "AtaraxiaSjel's NUR repository";
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    devenv.url = "github:cachix/devenv";
    devenv-root = {
      url = "file+file:///dev/null";
      flake = false;
    };
  };
  outputs =
    inputs@{ flake-parts, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
      ];
      imports = [
        inputs.devenv.flakeModule
      ];
      perSystem =
        {
          pkgs,
          lib,
          system,
          ...
        }:
        {
          _module.args.pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          legacyPackages = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            # overlays = [ (import ./overlay.nix) ];
            overlays = [
              (
                _: prev:
                (
                  let
                    ci = import ./ci.nix {
                      pkgs = prev;
                      inherit lib system;
                    };
                  in
                  ci.notReserved
                )
              )
            ];
          };
          # packages = lib.filterAttrs (_: v: lib.isDerivation v) legacyPackages;
          # Get all packages from ci.nix
          packages = (import ./ci.nix { inherit pkgs lib system; }).buildPkgs;
          checks = (import ./ci.nix { inherit pkgs lib system; }).cachePkgs;
          devenv.shells = rec {
            dev = {
              devenv.root =
                let
                  devenvRootFileContent = builtins.readFile inputs.devenv-root.outPath;
                in
                lib.mkIf (devenvRootFileContent != "") devenvRootFileContent;

              packages = with pkgs; [
                nix-update
                nix-eval-jobs
                nix-fast-build
                jq
              ];
              # https://github.com/cachix/devenv/issues/528
              containers = lib.mkForce { };
            };
            default = lib.recursiveUpdate dev {
              git-hooks.hooks = {
                actionlint.enable = true;
                deadnix.enable = true;
                flake-checker.enable = true;
                nixfmt-rfc-style.enable = true;
                ripsecrets.enable = true;
              };
            };
          };
        };
      flake = {
        lib = import ./lib;
        overlays = import ./overlays;
        nixosModules = import ./modules;
      };
    };

  nixConfig = {
    extra-substituters = [ "https://ataraxiadev-foss.cachix.org" ];
    extra-trusted-public-keys = [
      "ataraxiadev-foss.cachix.org-1:ws/jmPRUF5R8TkirnV1b525lP9F/uTBsz2KraV61058="
    ];
  };
}
