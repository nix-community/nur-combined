{
  description = "My System Config";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";
    unstable.url = "nixpkgs/nixos-unstable";
    parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix.url = "github:Mic92/sops-nix";
    nur.url = "github:nix-community/NUR";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database.url = "github:Mic92/nix-index-database";
    ai.url = "github:eownerdead/nixified-ai";
  };

  outputs = inputs@{ self, parts, ... }:
    parts.lib.mkFlake { inherit inputs; } rec {
      imports = [ ./hosts ];
      systems = [ "x86_64-linux" ];

      perSystem = { config, pkgs, system, ... }: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [
            inputs.nur.overlay
            (self: super: {
              unstable = import inputs.unstable { inherit system; };
              my = import ./pkgs { pkgs = super; };
              ai = inputs.ai.packages.${system};
            })
          ];
          config.allowUnfreePredicate = pkg:
            builtins.elem (inputs.nixpkgs.lib.getName pkg) [
              "nvidia-x11"
              "nvidia-settings"
            ];
        };

        formatter = pkgs.nixfmt;

        packages = import ./pkgs { inherit pkgs; };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            nixfmt
            editorconfig-checker
            statix
            nix-init
            nurl
            sops
          ];
        };
      };

      flake = {
        nixosConfig = {
          substituters =
            [ "https://nix-community.cachix.org" "https://ai.cachix.org" ];
          trusted-public-keys = [
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "ai.cachix.org-1:N9dzRK+alWwoKXQlnn0H6aUx0lU/mspIoz8hMvGvbbc="
          ];
        };

        overlays = rec {
          eownerdead = self: super: {
            eownerdead = import ./pkgs { pkgs = super; };
          };
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
    };
}

