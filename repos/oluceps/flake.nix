{
  description = "oluceps' flake";
  outputs =
    inputs@{
      flake-parts,
      vaultix,
      self,
      ...
    }:
    let
      extraLibs = import ./hosts/lib.nix inputs;
      flakeModules = map (n: inputs.${n}.flakeModule);
      defaultOverlays = map (n: inputs.${n}.overlays.default);
    in
    flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:
      {
        imports =
          (flakeModules [
            "pre-commit-hooks"
            "flake-root"
          ])
          ++ [
            ./hosts
            (import ./topo.nix extraLibs)
            vaultix.flakeModules.default
            inputs.nix-topology.flakeModule
            flake-parts.flakeModules.easyOverlay
          ];
        debug = true;
        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "riscv64-linux"
        ];
        perSystem =
          {
            pkgs,
            system,
            config,
            lib,
            ...
          }:
          {
            _module.args.pkgs = import inputs.nixpkgs {
              inherit system;
              overlays = defaultOverlays [
                "fenix"
                "self"
                "nuenv"
              ];
              config = {
                allowUnfreePredicate =
                  pkg:
                  builtins.elem (lib.getName pkg) [
                    "veracrypt"
                    "tetrio-desktop"
                  ];
              };
            };
            overlayAttrs = config.packages;

            pre-commit = {
              check.enable = true;
              settings.hooks = {
                nixfmt-rfc-style.enable = true;
                detect-private-keys.enable = true;
              };
            };

            # flake-root.projectRootFile = ".top";
            devShells.default = pkgs.mkShell {
              shellHook = config.pre-commit.installationScript;
              inputsFrom = [ config.flake-root.devShell ];
              buildInputs = with pkgs; [
                just
                rage
                b3sum
                nushell
                radicle-node
              ];
            };

            packages =
              (lib.packagesFromDirectoryRecursive {
                inherit (pkgs) callPackage;
                directory = ./pkgs/by-name;
              })
              // {
                default = pkgs.symlinkJoin {
                  name = "user-pkgs";
                  paths = import ./userPkgs.nix { inherit pkgs; };
                };
              };
            formatter = pkgs.nixfmt-tree;
          };

        flake = {
          vaultix = {
            nodes =
              let
                inherit (inputs.nixpkgs.lib) filterAttrs elem;
              in
              filterAttrs (
                n: _:
                !elem n [
                  # "yidhra"
                  "resq"
                  "livecd"
                  "bootstrap"
                  # "hastur"
                  # "kaambl"
                ]
              ) self.nixosConfigurations;
            identity = self + "/sec/age-yubikey-identity-7d5d5540.txt.pub";
            extraRecipients = [ extraLibs.data.keys.ageKey ];
            defaultSecretDirectory = "./sec";
            cache = "./sec/.cache";
          };
          lib = inputs.nixpkgs.lib.extend self.overlays.lib;

          overlays.lib = final: prev: extraLibs;

          nixosModules =
            let
              shadowedModules = [ ];
              modules =
                let
                  genModule =
                    dir: extraLibs.genFilteredDirAttrsV2 dir shadowedModules (n: import (dir + "/${n}.nix"));
                in
                (genModule ./modules) // { repack = ./repack; };

              default =
                { ... }:
                {
                  imports = builtins.attrValues modules;
                };
            in
            modules // { inherit default; };
        };
      }
    );

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    # nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpkgs-22.url = "github:NixOS/nixpkgs?rev=c91d0713ac476dfb367bbe12a7a048f6162f039c";
    nixpkgs-factorio.url = "github:NixOS/nixpkgs?rev=1b9bd8dd0fd5b8be7fc3435f7446272354624b01";

    nix-topology.url = "github:oddlama/nix-topology";
    niri = {
      url = "github:YaLTeR/niri";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    xwayland-satellite = {
      url = "github:Supreeeme/xwayland-satellite";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    browser-previews = {
      url = "github:nix-community/browser-previews";
    };
    vaultix.url = "github:milieuim/vaultix";
    # vaultix.url = "/home/riro/Src/vaultix";
    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lemurs = {
      url = "github:coastalwhite/lemurs";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    ascii2char = {
      url = "github:oluceps/nix-ascii2char";
    };
    # lix = {
    #   url = "git+https://git.lix.systems/lix-project/lix";
    #   flake = false;
    # };
    # lix-module = {
    #   url = "git+https://git.lix.systems/lix-project/nixos-module";
    #   inputs.lix.follows = "lix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    radicle = {
      url = "git+https://seed.radicle.xyz/z3gqcJUoA1n9HaHKufZs5FCSGazv5.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tg-online-keeper.url = "github:oluceps/TelegramOnlineKeeper";
    # tg-online-keeper.url = "/home/elen/Src/tg-online-keeper";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin.url = "github:catppuccin/nix";
    atuin = {
      url = "github:atuinsh/atuin";
    };
    conduit = {
      url = "github:matrix-construct/tuwunel?rev=f2c531429622dcc2f6bf96937e8e1def963cab79";
    };
    nyx = {
      # url = "/home/elen/Src/nyx";
      url = "github:chaotic-cx/nyx";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    factorio-manager = {
      url = "github:asoul-rec/factorio-manager";
      # url = "/home/elen/Src/factorio-manager";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    anyrun = {
      url = "github:Kirottu/anyrun";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    aagl = {
      url = "github:ezKEa/aagl-gtk-on-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs";
    };
    # path:/home/riro/Src/flake.nix
    dae.url = "github:oluceps/flake.nix/next";
    # dae.url = "/home/elen/Src/flake.nix";
    nixyDomains.url = "github:oluceps/nixyDomains";
    nixyDomains.flake = false;
    nuenv.url = "github:DeterminateSystems/nuenv";
    nix-direnv.url = "github:nix-community/nix-direnv";
    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
    };
    preservation.url = "github:WilliButz/preservation";
    prismlauncher = {
      url = "github:PrismLauncher/PrismLauncher";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-root.url = "github:srid/flake-root";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    devenv.url = "github:cachix/devenv";
    pgvectors-nixpkgs.url = "github:NixOS/nixpkgs?rev=b468a08276b1e2709168a4d8f04c63360c2140a9";
    microvm = {
      url = "github:microvm-nix/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
