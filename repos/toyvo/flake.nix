{
  description = "Collin Diekvoss Nix Configurations and NUR packages";

  inputs = {
    apple-silicon-support.url = "github:tpwrules/nixos-apple-silicon";
    catppuccin.url = "github:catppuccin/nix";
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixos-unstable";
    };
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixos-unstable";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixos-unstable";
    };
    ekapkgs.url = "github:ekala-project/ekapkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    hermes-agent.url = "github:NousResearch/hermes-agent";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixos-unstable";
    };
    jovian.url = "github:Jovian-Experiments/Jovian-NixOS";
    mac-app-util.url = "github:hraban/mac-app-util";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixos-unstable";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixos-unstable";
    };
    nixos-avf = {
      url = "github:nix-community/nixos-avf?ref=pull/45/merge";
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
    odysseus = {
      url = "github:odysseus-dev/odysseus/dev";
      flake = false;
    };
    pi = {
      url = "github:earendil-works/pi";
      inputs.nixpkgs.follows = "nixos-unstable";
    };
    plasma-manager.url = "github:pjones/plasma-manager";
    preservation.url = "github:nix-community/preservation";
    rust-overlay.url = "github:oxalica/rust-overlay";
    sops-nix.url = "github:Mic92/sops-nix";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    tuios.url = "github:Gaurav-Gosain/tuios";
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
          osModules = import ./modules/os;
          flakeModules = import ./modules/flake;
          modules = {
            nixos = self.nixosModules;
            darwin = self.darwinModules;
            flake = self.flakeModules;
            home = self.homeModules;
            os = self.osModules;
          };
          overlays = import ./overlays;
          nixosConfigurations = configurations.nixosConfigurations;
          darwinConfigurations = configurations.darwinConfigurations;
          homeConfigurations = configurations.homeConfigurations;

          # Deploy nodes are generated from `configurations`: every
          # nixos/darwin config becomes a node with inferred type, system,
          # hostname, and user. Standalone home-manager machines and other
          # exceptions live in `deployOverrides` below, which wins over the
          # generated set. Adding a standard host to
          # `configurations/default.nix` is enough to make it deployable.
          deploy.nodes =
            let
              configsFor =
                type:
                if type == "nixos" then
                  configurations.nixosConfigurations
                else if type == "darwin" then
                  configurations.darwinConfigurations
                else
                  configurations.homeConfigurations;
              configsAttr =
                type:
                if type == "nixos" then
                  "nixosConfigurations"
                else if type == "darwin" then
                  "darwinConfigurations"
                else
                  "homeConfigurations";
              mkNode =
                {
                  type,
                  system,
                  config,
                  hostname,
                  user,
                }:
                {
                  inherit hostname;
                  profiles.system = {
                    inherit user;
                    path = deploy-rs.lib.${system}.activate.${type} self.${configsAttr type}.${config};
                  };
                };
              autoNodes =
                type:
                builtins.mapAttrs (
                  name: _:
                  mkNode {
                    inherit type;
                    system = configurations.${configsAttr type}.${name}.pkgs.stdenv.hostPlatform.system;
                    config = name;
                    hostname = name;
                    user = "toyvo";
                  }
                ) (configsFor type);
              deployOverrides = {
                pixel10a = mkNode {
                  type = "home-manager";
                  system = "aarch64-linux";
                  config = "droid@debian";
                  hostname = "debian";
                  user = "droid";
                };
                # Deploys the pixel10a NixOS config under a distinct node
                # name (pixel10a itself is the home-manager node above).
                pixel10a-nixos = mkNode {
                  type = "nixos";
                  system = configurations.nixosConfigurations.pixel10a.pkgs.stdenv.hostPlatform.system;
                  config = "pixel10a";
                  hostname = "pixel10a";
                  user = "toyvo";
                };
                steamdeck = mkNode {
                  type = "home-manager";
                  system = "x86_64-linux";
                  config = "deck@steamdeck";
                  hostname = "steamdeck";
                  user = "deck";
                };
              };
            in
            autoNodes "nixos" // autoNodes "darwin" // deployOverrides;
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
            ekaPkgs,
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
                ];
                config = {
                  allowUnfree = true;
                  android_sdk.accept_license = true;
                };
              };
              ekaPkgs = import inputs.ekapkgs {
                inherit system;
                config.allowUnfree = true;
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
              # Bun runs the per-package `update.ts` scripts (`bun ./update.ts`).
              packages = [ pkgs.bun ];
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
              let
                pkgChecks = builtins.listToAttrs (
                  builtins.concatMap (
                    { path, drv }:
                    map
                      (
                        o:
                        lib.nameValuePair "${lib.concatStringsSep "-" path}${
                          lib.optionalString (o != "out") "-${o}"
                        }" drv.${o}
                      )
                      (
                        builtins.filter (
                          o:
                          let
                            p = drv.${o};
                          in
                          self.lib.isBuildable p && self.lib.isCacheable p && self.lib.forSystem system p
                        ) drv.outputs
                      )
                  ) (self.lib.flattenPkgsWithPaths self'.packages)
                );
                extraChecks =
                  lib.mapAttrs' (n: lib.nameValuePair "devShells-${n}") (
                    lib.filterAttrs (n: v: self.lib.isCacheable v) self'.devShells
                  )
                  // (deploy-rs-checks.${system} or { });
                allChecks = pkgChecks // extraChecks;
                # Round-robin partition over sorted names so version bombs
                # (e.g. 150 MC-server derivations) spread evenly. Each shard
                # is built by a separate `nix build` in CI, so no single
                # process ever evaluates the whole closure (the OOM killer
                # that took the nas runner at ~19 GB RSS).
                sortedNames = builtins.sort builtins.lessThan (builtins.attrNames allChecks);
                shardNames =
                  k:
                  builtins.concatLists (
                    builtins.genList (
                      i: if i - 4 * builtins.div i 4 == k then [ (builtins.elemAt sortedNames i) ] else [ ]
                    ) (builtins.length sortedNames)
                  );
                mkShard =
                  k:
                  pkgs.runCommand "checks-all-shard-${toString (k + 1)}" {
                    buildInputs = map (n: allChecks.${n}) (shardNames k);
                  } "touch $out";
              in
              allChecks
              // {
                all-shard-1 = mkShard 0;
                all-shard-2 = mkShard 1;
                all-shard-3 = mkShard 2;
                all-shard-4 = mkShard 3;
              };
          };
      }
    );
}
