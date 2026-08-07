{
  description = "Collin Diekvoss Nix Configurations and NUR packages";

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://cache.toyvo.dev"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.toyvo.dev:6bv4Qc2/SVaWnWzDOUcoB4pT3i3l4wcM+WrhRBFb7E4="
    ];
  };

  inputs = {
    apple-silicon-support.url = "github:tpwrules/nixos-apple-silicon";
    catppuccin.url = "github:catppuccin/nix";
    # Raw (unbuilt) starship port source. catppuccin/nix's starship module
    # imports the theme TOML at eval time (IFD) from the whiskers-built
    # package, which breaks cross-platform evaluation (e.g. evaluating
    # darwin configs on x86_64-linux CI). Point catppuccin.sources.starship
    # at this instead. Rev mirrors catppuccin/nix's pkgs/sources.json.
    catppuccin-starship = {
      url = "github:catppuccin/starship/5906cc369dd8207e063c0e6e2d27bd0c0b567cb8";
      flake = false;
    };
    # Same IFD workaround as catppuccin-starship, for rio. Rev mirrors
    # catppuccin/nix's pkgs/sources.json.
    catppuccin-rio = {
      url = "github:catppuccin/rio/4d37b8334a3e8f853fc6543dc2a60c295a66ddca";
      flake = false;
    };
    # Same IFD workaround, for the palette (NixOS tty module reads
    # palette.json at eval time). Rev mirrors catppuccin/nix's
    # pkgs/sources.json.
    catppuccin-palette = {
      url = "github:catppuccin/palette/07d02aa110ef9eb7e7427afca5c73ba9cf7f8ebd";
      flake = false;
    };
    deploy-rs.url = "github:serokell/deploy-rs";
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixos-unstable";
    };
    dioxus_monorepo.url = "github:toyvo/dioxus_monorepo";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixos-unstable";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    hermes-agent.url = "github:NousResearch/hermes-agent";
    hermes-webui = {
      url = "github:nesquena/hermes-webui";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixos-unstable";
    };
    jovian.url = "github:Jovian-Experiments/Jovian-NixOS";
    mac-app-util.url = "github:hraban/mac-app-util";
    nh.url = "github:toyvo/nh";
    odysseus = {
      url = "github:pewdiepie-archdaemon/odysseus/pull/2568/head";
      inputs.nixpkgs.follows = "nixos-unstable";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixos-unstable";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixos-unstable";
    };
    nixos-avf = {
      url = "github:nix-community/nixos-avf";
      inputs.nixpkgs.follows = "nixos-unstable";
    };
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-wsl.url = "github:nix-community/nixos-wsl";
    nixpkgs-esp-dev.url = "github:mirrexagon/nixpkgs-esp-dev";
    nixos-stable.url = "github:nixos/nixpkgs/nixos-26.05";
    nixos-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nur.url = "github:nix-community/nur";
    nvf.url = "github:NotAShelf/nvf";
    plasma-manager.url = "github:pjones/plasma-manager";
    preservation.url = "github:WilliButz/preservation";
    rust-overlay.url = "github:oxalica/rust-overlay";
    sops-nix.url = "github:Mic92/sops-nix";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    zed.url = "github:zed-industries/zed";
  };

  outputs =
    flake_inputs@{
      deploy-rs,
      devshell,
      flake-parts,
      nixpkgs-esp-dev,
      nixos-unstable,
      nur,
      rust-overlay,
      self,
      treefmt-nix,
      zed,
      ...
    }:
    let
      inputs = flake_inputs // {
        nixcfg = self;
      };
      configurations = import ./configurations inputs;
    in
    flake-parts.lib.mkFlake { inherit inputs; } (
      {
        config,
        moduleWithSystem,
        withSystem,
        ...
      }:
      {
        flake = {
          lib = import ./lib {
            lib = nixos-unstable.lib;
            inherit inputs;
          };
          nixosModules = import ./modules/nixos;
          homeModules = import ./modules/home;
          darwinModules = import ./modules/darwin;
          flakeModules = import ./modules/flake;
          modules = {
            nixos = self.nixosModules;
            darwin = self.darwinModules;
            flake = self.flakeModules;
            home = self.homeModules;
          };
          overlays = import ./overlays;
          nixosConfigurations = configurations.nixosConfigurations;
          darwinConfigurations = configurations.darwinConfigurations;
          homeConfigurations = configurations.homeConfigurations;

          deploy.nodes.nas = {
            hostname = "nas";
            profiles.system = {
              user = "toyvo";
              path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.nas;
            };
          };
        };
        systems = nixos-unstable.lib.systems.flakeExposed;
        imports = [
          devshell.flakeModule
          flake-parts.flakeModules.easyOverlay
          treefmt-nix.flakeModule
        ];
        perSystem =
          {
            config,
            lib,
            pkgs,
            system,
            self',
            ...
          }:
          {
            _module.args = {
              pkgs = import nixos-unstable {
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
            };

            treefmt = {
              programs = {
                nixfmt.enable = true;
                prettier.enable = true;
                yamlfmt.enable = true;
                mdformat.enable = true;
              };
            };
            legacyPackages = import ./default.nix {
              inherit pkgs inputs;
            };
            packages = lib.filterAttrs (_: v: lib.isDerivation v) self'.legacyPackages;
            overlayAttrs.toyvo = self'.legacyPackages;
            devshells.default = {
              commands = [
                {
                  package = self'.packages.setup-sops;
                }
              ];
              imports = [ "${devshell}/extra/git/hooks.nix" ];
              git.hooks = {
                enable = true;
                pre-commit.text = self'.legacyPackages.pre-commit.text;
                pre-push.text = self'.legacyPackages.pre-push.text;
              };
            };

            checks =
              builtins.listToAttrs (
                map
                  (n: lib.nameValuePair (lib.removePrefix "/nix/store/" (lib.strings.unsafeDiscardStringContext n)) n)
                  (
                    builtins.filter (
                      p: self.lib.isBuildable p && self.lib.isCacheable p && self.lib.forSystem system p
                    ) (builtins.concatMap self.lib.outputsOf (self.lib.flattenPkgs self'.packages))
                  )
              )
              // lib.mapAttrs' (n: lib.nameValuePair "devShells-${n}") (
                lib.filterAttrs (n: v: self.lib.isCacheable v) self'.devShells
              );

          };
      }
    );
}
