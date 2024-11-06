{
  description = "oluceps' flake";
  outputs =
    inputs@{ flake-parts, self, ... }:
    let
      extraLibs = (import ./hosts/lib.nix inputs);
      flakeModules = map (n: inputs.${n}.flakeModule);
      defaultOverlays = map (n: inputs.${n}.overlays.default);
    in
    flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:
      {
        imports =
          (flakeModules [
            "pre-commit-hooks"
            "devshell"
          ])
          ++ [
            ./hosts
            inputs.vaultix.flakeModules.default
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

            pre-commit = {
              check.enable = true;
              settings.hooks = {
                nixfmt-rfc-style.enable = true;
              };
            };

            devshells.default.devshell = {
              packages = with pkgs; [
                just
                rage
                b3sum
                nushell
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
            formatter = pkgs.nixfmt-rfc-style;
            vaultix.nodes =
              let
                inherit (inputs.nixpkgs.lib) filterAttrs elem;
              in
              filterAttrs (
                n: _:
                !elem n [
                  "resq"
                  "livecd"
                  "bootstrap"
                ]
              ) self.nixosConfigurations;
          };

        flake = {
          lib = inputs.nixpkgs.lib.extend self.overlays.lib;

          overlays = {
            default =
              final: prev:
              prev.lib.packagesFromDirectoryRecursive {
                inherit (prev) callPackage;
                directory = ./pkgs/by-name;
              };

            lib = final: prev: extraLibs;
          };

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
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpkgs-22.url = "github:NixOS/nixpkgs?rev=c91d0713ac476dfb367bbe12a7a048f6162f039c";
    niri.url = "github:sodiboo/niri-flake";
    nixpkgs-factorio.url = "github:NixOS/nixpkgs?rev=1b9bd8dd0fd5b8be7fc3435f7446272354624b01";
    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    browser-previews = {
      url = "github:nix-community/browser-previews";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vaultix.url = "github:oluceps/vaultix/dev";
    # vaultix.url = "/home/elen/Src/vaultix";
    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ascii2char = {
      url = "github:oluceps/nix-ascii2char";
    };
    lix = {
      url = "git+https://git.lix.systems/lix-project/lix";
      flake = false;
    };
    lix-module = {
      url = "git+https://git.lix.systems/lix-project/nixos-module";
      inputs.lix.follows = "lix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    radicle = {
      url = "git+https://seed.radicle.xyz/z3gqcJUoA1n9HaHKufZs5FCSGazv5.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devshell.url = "github:numtide/devshell";
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
      url = "github:girlbossceo/conduwuit";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    nyx = {
      # url = "/home/elen/Src/nyx";
      url = "github:oluceps/nyx/opt";
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
    dae.url = "github:daeuniverse/flake.nix/dev";
    nixyDomains.url = "github:oluceps/nixyDomains";
    nixyDomains.flake = false;
    nuenv.url = "github:DeterminateSystems/nuenv";
    nixd.url = "github:nix-community/nixd";
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
    helix.url = "github:helix-editor/helix";
    berberman.url = "github:berberman/flakes";
  };
}
