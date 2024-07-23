{
  description = "Weathercold's NixOS Flake";

  inputs = {
    # Repos
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    ## TODO: Actually use
    # nur.url = "github:nix-community/NUR";
    nixd = {
      url = "github:nix-community/nixd";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };
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
    home-manager = {
      # Fork to add option to specify default specialisation
      url = "github:Weathercold/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin.url = "github:catppuccin/nix";
    # catppuccin.url = "github:Weathercold/nix/patch";
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
          "armv7l-linux"
        ];

        perSystem =
          { inputs', pkgs, ... }:
          with pkgs;
          {
            formatter = nixfmt-rfc-style;

            devShells.default = mkShell {
              packages = [
                cachix
                deploy-rs
                inputs'.nixd.packages.nixd
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
