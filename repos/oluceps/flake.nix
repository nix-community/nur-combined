{
  description = "oluceps' flake";
  outputs =
    inputs@{ flake-parts, ... }:
    let
      extraLibs = (import ./hosts/lib.nix inputs);
    in
    flake-parts.lib.mkFlake { inherit inputs; } (
      { withSystem, ... }:
      {
        imports =
          (with inputs; [
            pre-commit-hooks.flakeModule
            devshell.flakeModule
          ])
          ++ [
            ./hosts
            ./hosts/livecd
            ./hosts/bootstrap
            ./hosts/resq
          ];
        debug = false;
        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "riscv64-linux"
        ];
        perSystem =
          {
            pkgs,
            system,
            inputs',
            ...
          }:
          {

            _module.args.pkgs = import inputs.nixpkgs {
              inherit system;
              overlays = with inputs; [
                agenix-rekey.overlays.default
                fenix.overlays.default
                colmena.overlays.default
                self.overlays.default
              ];
            };

            pre-commit = {
              check.enable = true;
            };

            devshells.default.devshell = {
              packages = with pkgs; [
                agenix-rekey
                just
                rage
                b3sum
                nushell
                colmena
              ];
            };

            packages =
              let
                shadowedPkgs = [
                  "glowsans" # multi pkgs
                  "opulr-a-run" # ?
                  "tcp-brutal" # kernelModule
                  "shufflecake"
                ];
              in
              (extraLibs.genFilteredDirAttrsV2 ./pkgs shadowedPkgs (n: pkgs.${n}));
            formatter = pkgs.nixfmt-rfc-style;
          };

        flake = {
          lib = inputs.nixpkgs.lib.extend inputs.self.overlays.lib;

          nixosConfigurations = ((inputs.colmena.lib.makeHive inputs.self.colmena).introspect (x: x)).nodes;

          agenix-rekey = inputs.agenix-rekey.configure {
            userFlake = inputs.self;
            nodes =
              with inputs.nixpkgs.lib;
              filterAttrs (
                n: _:
                !elem n [
                  "resq"
                  "livecd"
                  "bootstrap"
                ]
              ) inputs.self.nixosConfigurations;
          };

          overlays = {
            default =
              final: prev:
              let
                shadowedPkgs = [
                  "tcp-brutal"
                  "shufflecake"
                ];
              in
              extraLibs.genFilteredDirAttrsV2 ./pkgs shadowedPkgs (
                name: final.callPackage (./pkgs + "/${name}.nix") { }
              );

            lib = final: prev: extraLibs;
          };

          nixosModules =
            let
              shadowedModules = [ "sundial" ];
              modules = extraLibs.genFilteredDirAttrsV2 ./modules shadowedModules (
                n: import (./modules + "/${n}.nix")
              );

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
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpkgs-22.url = "github:NixOS/nixpkgs?rev=c91d0713ac476dfb367bbe12a7a048f6162f039c";
    niri.url = "github:sodiboo/niri-flake";
    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    radicle = {
      url = "git+https://seed.radicle.xyz/z3gqcJUoA1n9HaHKufZs5FCSGazv5.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    attic = {
      url = "github:zhaofengli/attic";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devshell.url = "github:numtide/devshell";
    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tg-online-keeper.url = "github:oluceps/TelegramOnlineKeeper";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    # tg-online-keeper.url = "/home/elen/Src/tg-online-keeper";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    atuin = {
      url = "github:atuinsh/atuin";
    };
    conduit = {
      url = "gitlab:famedly/conduit";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nyx = {
      # url = "/home/elen/Src/nyx";
      url = "github:oluceps/nyx";
    };
    factorio-manager = {
      url = "github:asoul-rec/factorio-manager";
      # url = "/home/elen/Src/factorio-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    anyrun = {
      url = "github:Kirottu/anyrun";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    j-link.url = "github:liff/j-link-flake";
    devenv.url = "github:cachix/devenv";
    aagl = {
      url = "github:ezKEa/aagl-gtk-on-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs";
    };
    # path:/home/riro/Src/flake.nix
    dae.url = "github:daeuniverse/flake.nix/unstable";
    # dae.url = "/home/elen/Src/flake.nix";
    # nixyDomains.url = "";
    nixyDomains.url = "github:oluceps/nixyDomains";
    nixyDomains.flake = false;
    nuenv.url = "github:DeterminateSystems/nuenv";
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    resign.url = "github:oluceps/resign";
    nil.url = "github:oxalica/nil";
    nix-direnv.url = "github:nix-community/nix-direnv";
    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    misskey = {
      url = "github:Ninlives/misskey.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ragenix = {
      url = "github:yaxitech/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.agenix.follows = "agenix";
    };
    agenix = {
      url = "github:oluceps/agenix/with-sysuser";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
    };
    impermanence.url = "github:nix-community/impermanence";
    prismlauncher = {
      url = "github:PrismLauncher/PrismLauncher";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager.url = "github:nix-community/home-manager";
    helix.url = "github:helix-editor/helix";
    berberman.url = "github:berberman/flakes";
    # clansty.url = "github:clansty/flake";
  };
}
