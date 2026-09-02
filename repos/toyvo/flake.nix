{
  description = "Collin Diekvoss Nix Configurations and NUR packages";

  inputs = {
    apple-silicon-support.url = "github:tpwrules/nixos-apple-silicon";
    catppuccin.url = "github:catppuccin/nix";
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
      url = "github:odysseus-dev/odysseus/dev";
      flake = false;
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
      # deployChecks is not platform-aware: it generates checks covering every
      # node in self.deploy, and those check derivations embed the outPaths of
      # every node's profile (via builtins.toJSON string context / script
      # interpolation), so they depend on *realizing* every profile path.
      # Without filtering, `nix flake check` on any host would try to build
      # all nodes' toplevels locally, failing on platform mismatches
      # (e.g. building x86_64-linux NixOS toplevels on aarch64-darwin).
      #
      # We therefore filter nodes to only those matching the check system.
      #
      # NOTE: if remote builders for all platforms are ever configured (e.g. a
      # linux builder on darwin hosts), this filter could be dropped so that a
      # single host validates every node. Until then, keep it.
      deploy-rs-checks = builtins.mapAttrs (
        system: deployLib:
        deployLib.deployChecks (
          self.deploy
          // {
            nodes = nixos-unstable.lib.filterAttrs (
              _: node:
              nixos-unstable.lib.all (profile: profile.path.system == system) (builtins.attrValues node.profiles)
            ) self.deploy.nodes;
          }
        )
      ) deploy-rs.lib;
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

          deploy.nodes = {
            HP-Envy = {
              hostname = "HP-Envy";
              profiles.system = {
                user = "toyvo";
                path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.HP-Envy;
              };
            };
            HP-ZBook = {
              hostname = "HP-ZBook";
              profiles.system = {
                user = "toyvo";
                path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.HP-ZBook;
              };
            };
            MacBook-Pro = {
              hostname = "MacBook-Pro";
              profiles.system = {
                user = "toyvo";
                path = deploy-rs.lib.aarch64-darwin.activate.darwin self.darwinConfigurations.MacBook-Pro;
              };
            };
            MacMini-M1 = {
              hostname = "MacMini-M1";
              profiles.system = {
                user = "toyvo";
                path = deploy-rs.lib.aarch64-darwin.activate.darwin self.darwinConfigurations.MacMini-M1;
              };
            };
            MacBook-Pro-NixOS = {
              hostname = "MacBook-Pro-NixOS";
              profiles.system = {
                user = "toyvo";
                path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.MacBook-Pro-NixOS;
              };
            };
            nas = {
              hostname = "nas";
              profiles.system = {
                user = "toyvo";
                path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.nas;
              };
            };
            oracle-cloud-nixos = {
              hostname = "oracle-cloud-nixos";
              profiles.system = {
                user = "toyvo";
                path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.oracle-cloud-nixos;
              };
            };
            PineBook-Pro = {
              hostname = "PineBook-Pro";
              profiles.system = {
                user = "toyvo";
                path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.PineBook-Pro;
              };
            };
            pixel10a = {
              hostname = "debian";
              profiles.system = {
                user = "droid";
                path = deploy-rs.lib.aarch64-linux.activate.home-manager self.homeConfigurations."droid@debian";
              };
            };
            pixel10a-nixos = {
              hostname = "pixel10a";
              profiles.system = {
                user = "toyvo";
                path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.pixel10a;
              };
            };
            Protectli = {
              hostname = "Protectli";
              profiles.system = {
                user = "toyvo";
                path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.Protectli;
              };
            };
            router = {
              hostname = "router";
              profiles.system = {
                user = "toyvo";
                path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.router;
              };
            };
            rpi4b4a = {
              hostname = "rpi4b4a";
              profiles.system = {
                user = "toyvo";
                path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.rpi4b4a;
              };
            };
            rpi4b8a = {
              hostname = "rpi4b8a";
              profiles.system = {
                user = "toyvo";
                path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.rpi4b8a;
              };
            };
            rpi4b8b = {
              hostname = "rpi4b8b";
              profiles.system = {
                user = "toyvo";
                path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.rpi4b8b;
              };
            };
            rpi4b8c = {
              hostname = "rpi4b8c";
              profiles.system = {
                user = "toyvo";
                path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.rpi4b8c;
              };
            };
            steamdeck = {
              hostname = "steamdeck";
              profiles.system = {
                user = "deck";
                path = deploy-rs.lib.x86_64-linux.activate.home-manager self.homeConfigurations."deck@steamdeck";
              };
            };
            steamdeck-nixos = {
              hostname = "steamdeck-nixos";
              profiles.system = {
                user = "toyvo";
                path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.steamdeck-nixos;
              };
            };
            Thinkpad = {
              hostname = "Thinkpad";
              profiles.system = {
                user = "toyvo";
                path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.Thinkpad;
              };
            };
            utm = {
              hostname = "utm";
              profiles.system = {
                user = "toyvo";
                path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.utm;
              };
            };
            wsl = {
              hostname = "wsl";
              profiles.system = {
                user = "toyvo";
                path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.wsl;
              };
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
              )
              // (deploy-rs-checks.${system} or { })
              // {
                # Aggregate of every check. Excludes itself by name to avoid infinite recursion.
                all = pkgs.runCommand "checks-all" {
                  buildInputs = builtins.attrValues (builtins.removeAttrs config.checks [ "all" ]);
                } "touch $out";
              };
          };
      }
    );
}
