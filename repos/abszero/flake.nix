{
  description = "Weathercold's NixOS Flake";

  inputs = {
    # Repos
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # bocchi-cursors = {
    #   url = "github:Weathercold/Bocchi-Cursors";
    #   inputs = {
    #     nixpkgs.follows = "nixpkgs";
    #     flake-parts.follows = "flake-parts";
    #   };
    # };

    # Utils
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
      };
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
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin.url = "github:catppuccin/nix";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-parts,
      ...
    }@inputs:

    let
      lib = import ./lib { inherit (nixpkgs) lib; };
      extLib = nixpkgs.lib.extend (_: _: { abszero = lib; });
    in

    flake-parts.lib.mkFlake
      {
        inherit inputs;
        specialArgs.lib = extLib;
      }
      {
        imports = [
          ./pkgs/flake-module.nix
          ./nixos/flake-module.nix
          ./home/flake-module.nix
        ];

        # Expose flake-parts options for nixd
        debug = true;

        flake = {
          # FIXME: This is suboptimal, would be better to put checks where
          # deploy is defined.
          checks.x86_64-linux = inputs.deploy-rs.lib.x86_64-linux.deployChecks self.deploy;
          inherit lib;
        };

        systems = [
          "x86_64-linux"
          "x86_64-darwin"
          "aarch64-darwin"
          "aarch64-linux"
        ];

        perSystem =
          { pkgs, ... }:
          with pkgs;
          {
            formatter = nixfmt-rfc-style;

            devShells.default = mkShell {
              packages = [
                cachix
                deploy-rs
                nixd
                nil
                nixfmt-rfc-style
                nixos-anywhere
                nix-init
                nix-prefetch-github # Somehow not in nix-prefetch-scripts
                nix-prefetch-scripts
              ];
              shellHook = ''
                export NIXPKGS_ALLOW_BROKEN=1
              '';
            };
          };
      };
}
