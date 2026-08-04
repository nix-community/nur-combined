{
  description = "My System Config";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    unstable.url = "nixpkgs/nixos-unstable";
    parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "";
      inputs.home-manager.follows = "";
    };
    nur.url = "github:nix-community/NUR";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs = {
        # nixpkgs.follows = "nixpkgs"; # binary cache
        pre-commit.follows = "";
      };
    };
    nix-index-database.url = "github:Mic92/nix-index-database";
    buildbot-nix = {
      url = "github:nix-community/buildbot-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "";
      };
    };
    hercules-ci-effects = {
      url = "github:hercules-ci/hercules-ci-effects";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "parts";
      };
    };
    docker-nixpkgs = {
      url = "github:nix-community/docker-nixpkgs";
      flake = false;
    };
    emacs-tramp-rpc = {
      url = "github:ArthurHeymans/emacs-tramp-rpc";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ parts, ... }:
    parts.lib.mkFlake { inherit inputs; } (
      {
        lib,
        self,
        withSystem,
        ...
      }:
      {
        imports = [
          ./hercules-ci.nix
          ./hosts
        ];
        systems = [ "x86_64-linux" ];

        perSystem =
          {
            config,
            pkgs,
            inputs',
            self',
            system,
            ...
          }:
          {
            _module.args.pkgs = import inputs.nixpkgs {
              inherit system;
              overlays = [
                self.overlays.eownerdead
                inputs.nur.overlays.default
                (self: super: {
                  unstable = import inputs.unstable { inherit system; };
                })
                (import "${inputs.docker-nixpkgs}/overlay.nix")
                inputs.emacs-tramp-rpc.overlays.default
              ];
              config = {
                allowUnfreePredicate =
                  pkg:
                  let
                    name = inputs.nixpkgs.lib.getName pkg;
                  in
                  builtins.elem name [
                    "nvidia-kernel-modules"
                    "nvidia-x11"
                    "nvidia-settings"
                    "libnvjitlink"
                    "libnpp"
                    "wpsoffice-mui"
                  ]
                  || (lib.hasPrefix "cuda" name)
                  || (lib.hasPrefix "libcu" name);
                allowInsecurePredicate = _: true;
              };
            };

            checks = self'.packages;

            packages = lib.filterAttrs (k: v: lib.isDerivation v) pkgs.eownerdead;

            formatter = pkgs.nixfmt;

            devShells.default = pkgs.mkShell {
              packages =
                (with pkgs; [
                  nixfmt
                  statix
                  deploy-rs # Binary cache
                  sbctl
                  nh
                ])
                ++ [
                  inputs'.disko.packages.disko
                  inputs'.disko.packages.disko-install
                  inputs'.buildbot-nix.packages.buildbot-effects
                ];
            };
          };

        flake = {
          nixosConfig = {
            substituters = [
              "https://nix-community.cachix.org"
            ];
            trusted-public-keys = [
              "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            ];
          };

          overlays = rec {
            eownerdead = import ./overlay.nix;
            default = eownerdead;
          };

          nixosModules = rec {
            eownerdead = import ./nixos;
            default = eownerdead;
          };

          templates.default = {
            description = "Default Generic Template";
            path = ./templates/default;
          };
        };
      }
    );
}
