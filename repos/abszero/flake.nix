{
  description = "Weathercold's NixOS Flake";

  nixConfig = {
    extra-substituters = [ "https://abszero.cachix.org" ];
    extra-trusted-public-keys = [ "abszero.cachix.org-1:HXOydaS51jSWrM07Ko8AVtGdoBRT9F+QhdYQBiNDaM0=" ];
  };

  inputs = {
    # Repos
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel/release";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };
    nixified-ai = {
      url = "github:nixified-ai/flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };
    driftwm = {
      url = "github:malbiruk/driftwm";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wisp = {
      url = "github:Weathercold/wisp";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        flake-compat.follows = "flake-compat";
      };
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    charmbracelet = {
      url = "github:charmbracelet/nur";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
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
    nixpkgs-patcher.url = "github:gepbird/nixpkgs-patcher";
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
      };
    };
    sops = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      # # Fork that adds an UKI mode
      # url = "github:linyinfeng/lanzaboote/uki";
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
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
      libAbszero = import ./lib { inherit (nixpkgs) lib; };
      lib = nixpkgs.lib.extend (_: _: { abszero = libAbszero; });
      inherit (lib) flatten;
      inherit (lib.abszero.filesystem) toModuleList;
    in

    flake-parts.lib.mkFlake
      {
        inherit inputs;
        specialArgs = { inherit lib; };
      }
      {
        imports = flatten [
          ./pkgs/flake-module.nix
          (toModuleList ./nixos/flake-modules)
          (toModuleList ./home/flake-modules)
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
          "aarch64-darwin"
          "aarch64-linux"
        ];

        perSystem =
          { pkgs, ... }:
          with pkgs;
          {
            formatter = nixfmt-tree;

            devShells.default = mkShell {
              packages = [
                bash-language-server
                cachix
                deploy-rs
                markdown-oxide
                nixd
                nixfmt
                nixfmt-tree
                nixos-anywhere
                nix-init
                nix-prefetch-github # Somehow not in nix-prefetch-scripts
                nix-prefetch-scripts
                nix-update
                tombi # TOML language server
                yaml-language-server
                vscode-langservers-extracted # For vscode-json-language-server
              ];
              shellHook = ''
                export NIXPKGS_ALLOW_BROKEN=1
              '';
            };
          };
      };
}
