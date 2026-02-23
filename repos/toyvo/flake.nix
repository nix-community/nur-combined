{
  description = "Collin Diekvoss Nix Configurations and NUR packages";

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://toyvo.cachix.org"
      "https://zed.cachix.org"
      "https://cache.garnix.io"
      "https://cache.toyvo.dev"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "toyvo.cachix.org-1:s++CG1te6YaS9mjICre0Ybbya2o/S9fZIyDNGiD4UXs="
      "zed.cachix.org-1:/pHQ6dpMsAZk2DiP4WCL0p9YDNKWj2Q5FL20bNmw1cU="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "cache.toyvo.dev:6bv4Qc2/SVaWnWzDOUcoB4pT3i3l4wcM+WrhRBFb7E4="
    ];
  };

  inputs = {
    apple-silicon-support.url = "github:tpwrules/nixos-apple-silicon";
    arion = {
      url = "github:hercules-ci/arion";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    catppuccin.url = "github:catppuccin/nix";
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    dioxus_monorepo.url = "github:toyvo/dioxus_monorepo";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    jovian.url = "github:Jovian-Experiments/Jovian-NixOS";
    mac-app-util.url = "github:hraban/mac-app-util";
    nh.url = "github:toyvo/nh";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-wsl.url = "github:nix-community/nixos-wsl";
    nixpkgs-esp-dev.url = "github:mirrexagon/nixpkgs-esp-dev";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/nur";
    nvf.url = "github:NotAShelf/nvf";
    openclaw-pr.url = "github:nixos/nixpkgs/pull/485407/head";
    plasma-manager.url = "github:pjones/plasma-manager";
    rust-overlay.url = "github:oxalica/rust-overlay";
    sops-nix.url = "github:Mic92/sops-nix";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    zed.url = "github:zed-industries/zed";
  };

  outputs =
    inputs@{
      devshell,
      flake-parts,
      nixpkgs-esp-dev,
      nixpkgs-unstable,
      nur,
      rust-overlay,
      self,
      treefmt-nix,
      zed,
      ...
    }:
    let
      configurations = import ./systems inputs;
      import_nixpkgs =
        system: nixpkgs:
        import nixpkgs {
          inherit system;
          overlays = [
            nixpkgs-esp-dev.overlays.default
            nur.overlays.default
            rust-overlay.overlays.default
            # zed.overlays.default
          ];
          config = {
            allowUnfree = true;
            android_sdk.accept_license = true;
          };
        };
      inherit (nixpkgs-unstable) lib;
      pkgsDir = "${self}/pkgs";
      libDir = "${self}/lib";
      # overlaysDir = "${self}/overlays";
      modulesDir = "${self}/modules";
    in
    flake-parts.lib.mkFlake { inherit inputs; } (
      {
        config,
        moduleWithSystem,
        withSystem,
        ...
      }:
      let
        ourLib =
          (import libDir { inherit lib; })
          // {
            inherit import_nixpkgs;
          }
          // configurations.lib;
        lib' = lib.recursiveUpdate lib ourLib;
      in
      {
        flake = {
          lib = ourLib;
          # overlays = lib'.importDirRecursive overlaysDir;
          modules = lib'.importDirRecursive modulesDir;
          nixosConfigurations = configurations.nixosConfigurations;
          darwinConfigurations = configurations.darwinConfigurations;
          homeConfigurations = configurations.homeConfigurations;
        };
        systems = lib.systems.flakeExposed;
        imports = [
          devshell.flakeModule
          flake-parts.flakeModules.easyOverlay
          treefmt-nix.flakeModule
        ];
        perSystem =
          {
            config,
            pkgs,
            system,
            self',
            ...
          }:
          with lib';
          let
            basePkgs = import_nixpkgs system nixpkgs-unstable;
            pkgs' = recursiveUpdate basePkgs { lib = lib'; };
            ourPackages = callDirPackageWithRecursive pkgs' pkgsDir;
          in
          {
            _module.args = {
              pkgs = pkgs';
            };

            treefmt = {
              programs = {
                nixfmt.enable = true;
                prettier.enable = true;
                yamlfmt.enable = true;
                mdformat.enable = true;
              };
            };
            legacyPackages = ourPackages // {
              # inherit (self) lib overlays modules;
              inherit (self) lib modules;
              maintainers = pkgs.callPackage "${self}/maintainers" { };
            };
            packages = flakePackages system ourPackages;
            overlayAttrs.toyvo = ourPackages;
            devshells.default = {
              commands = [
                {
                  package = self'.packages.setup-sops;
                }
                {
                  package = self'.packages.setup-git-sops;
                }
              ];
              imports = [ "${devshell}/extra/git/hooks.nix" ];
              git.hooks = {
                enable = true;
                pre-commit.text = self'.legacyPackages.pre-commit.text;
                pre-push.text = self'.legacyPackages.pre-push.text;
              };
            };
            # we get infinite recursion on freebsd with `nix flake show`, not investigating
            checks = lib.mkIf (system != "x86_64-freebsd") (
              flakeChecks system self'.packages
              // mapAttrs' (n: nameValuePair "devShells-${n}") (filterAttrs (n: v: isCacheable v) self'.devShells)
            );
          };
      }
    );
}
