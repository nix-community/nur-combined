{
  description = "My System Config";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
    unstable.url = "nixpkgs/nixos-unstable";
    parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    sops-nix.url = "github:Mic92/sops-nix";
    nur.url = "github:nix-community/NUR";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database.url = "github:Mic92/nix-index-database";
    docker-nixpkgs = {
      url = "github:nix-community/docker-nixpkgs";
      flake = false;
    };
  };

  outputs =
    inputs@{ self, parts, ... }:
    let
      inherit (inputs.nixpkgs) lib;
    in
    parts.lib.mkFlake { inherit inputs; } rec {
      imports = [ ./hosts ];
      systems = [ "x86_64-linux" ];

      perSystem =
        {
          config,
          pkgs,
          system,
          ...
        }:
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [
              inputs.nur.overlay
              (self: super: {
                unstable = import inputs.unstable { inherit system; };
                my = import ./pkgs { pkgs = super; };
                ai = inputs.ai.packages.${system};
              })
              (import "${inputs.docker-nixpkgs}/overlay.nix")
            ];
            config = {
              allowUnfreePredicate =
                pkg:
                let
                  name = inputs.nixpkgs.lib.getName pkg;
                in
                builtins.elem name [
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

          formatter = pkgs.nixfmt-rfc-style;

          packages = import ./pkgs { inherit pkgs; };

          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              nixfmt-rfc-style
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
          substituters = [
            "https://nix-community.cachix.org"
            "https://ai.cachix.org"
          ];
          trusted-public-keys = [
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "ai.cachix.org-1:N9dzRK+alWwoKXQlnn0H6aUx0lU/mspIoz8hMvGvbbc="
          ];
        };

        overlays = rec {
          eownerdead = self: super: { eownerdead = import ./pkgs { pkgs = super; }; };
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
