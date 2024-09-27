{
  description = "Weathercold's NixOS modules";

  inputs = {
    # Repos
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Utils
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    haumea = {
      url = "github:nix-community/haumea";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    lanzaboote = {
      # Fork that adds an UKI mode
      url = "github:linyinfeng/lanzaboote/uki";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };
    # catppuccin.url = "github:catppuccin/nix";
    catppuccin.url = "github:Weathercold/nix/patch";
  };

  outputs =
    {
      nixpkgs,
      flake-parts,
      haumea,
      ...
    }@inputs:
    let
      extendedLib = nixpkgs.lib.extend (
        _: _: {
          abszero = import ../lib {
            inherit (nixpkgs) lib;
            inherit haumea;
          };
        }
      );
    in
    flake-parts.lib.mkFlake
      {
        inherit inputs;
        specialArgs.lib = extendedLib;
      }
      {
        imports = [ ./flake-module.nix ];

        systems = [ "x86_64-linux" ];
      };
}
