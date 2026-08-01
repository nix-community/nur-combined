{
  description = "iamanaws' nix flake";

  inputs = {
    #### Nixpkgs ####

    # Nixpkgs source, pinned for the entire system
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents.url = "github:numtide/llm-agents.nix";

    #### NIXOS ####

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-mineral.url = "github:cynicsketch/nix-mineral/v0.3.3-alpha";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nix-flatpak.url = "github:gmodena/nix-flatpak";

    #### DARWIN ####

    nix-darwin = {
      # url = "github:nix-darwin/nix-darwin";
      url = "github:iamanaws/nix-darwin/staging";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    #### Home manager ####
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Shameless plug: looking for a way to nixify your themes and make
    # nix-colors.url = "github:misterio77/nix-colors";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      inherit (self) outputs;

      lib = nixpkgs.lib;

      mkNixos = import ./lib/mkNixos.nix { inherit inputs outputs; };
      mkDarwin = import ./lib/mkDarwin.nix { inherit inputs outputs; };
      mkHome = import ./lib/mkHome.nix {
        inherit
          inputs
          outputs
          nixpkgs
          lib
          ;
      };

      nixosHosts = lib.attrNames (
        lib.filterAttrs (_: v: v == "directory") (builtins.readDir ./nixos/hosts)
      );

      darwinHosts = lib.attrNames (
        lib.filterAttrs (_: v: v == "directory") (builtins.readDir ./darwin/hosts)
      );

      forAllSystems =
        f:
        lib.genAttrs lib.systems.flakeExposed (
          system:
          f (
            import nixpkgs {
              inherit system;
              config = import ./lib/nixpkgsConfig.nix { inherit lib; };
            }
          )
        );
    in
    {
      formatter = forAllSystems (pkgs: pkgs.nixfmt-tree);
      packages = forAllSystems (
        pkgs:
        let
          all = import ./pkgs { inherit pkgs; };
        in
        lib.filterAttrs (_: v: lib.isDerivation v && lib.meta.availableOn pkgs.stdenv.hostPlatform v) all
      );
      overlays = import ./overlays { inherit (inputs) nur; };

      ### NixOS Configurations ###
      nixosConfigurations = lib.genAttrs nixosHosts (
        hostName:
        mkNixos {
          name = hostName;
          path = ./nixos/hosts + "/${hostName}";
        }
      );

      ### Darwin Configurations ###
      darwinConfigurations = lib.genAttrs darwinHosts (
        hostName:
        mkDarwin {
          name = hostName;
          path = ./darwin/hosts + "/${hostName}";
        }
      );

      ### Home-Manager standalone configurations ###
      homeConfigurations = mkHome;
    };
}
