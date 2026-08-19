{
  description = "Weathercold's home-manager modules";

  inputs = {
    # Repos
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
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
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    nixpkgs-patcher.url = "github:gepbird/nixpkgs-patcher";
    sops = {
      url = "github:Mic92/sops-nix";
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
      nixpkgs,
      flake-parts,
      ...
    }@inputs:
    let
      libAbszero = import ../lib { inherit (nixpkgs) lib; };
      lib = nixpkgs.lib.extend (_: _: { abszero = libAbszero; });
      inherit (lib.abszero.filesystem) toModuleList;
    in
    flake-parts.lib.mkFlake
      {
        inherit inputs;
        specialArgs = { inherit lib; };
      }
      {
        imports = toModuleList ./flake-modules;

        systems = [
          "x86_64-linux"
          "aarch64-darwin"
          "aarch64-linux"
        ];
      };
}
