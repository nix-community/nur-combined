{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-22.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nur.url = "github:nix-community/NUR";

    impermanence.url = "github:nix-community/impermanence";

    darkmatter-grub-theme.url = "gitlab:VandalByte/darkmatter-grub-theme";
    darkmatter-grub-theme.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:Mic92/nix-index-database";

    haumea = {
      url = "github:nix-community/haumea";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, haumea, ... } @inputs:
    let
      modules = haumea.lib.load {
        src = ./modules;
        loader = haumea.lib.loaders.verbatim;
      };
      hosts = haumea.lib.load {
        src = ./hosts;
        loader = haumea.lib.loaders.verbatim;
      };
    in
    haumea.lib.load {
      src = ./outputs;
      inputs = {
        inherit modules hosts inputs;
        inherit (nixpkgs) lib;
      };
    };
}
