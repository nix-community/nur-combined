{
  description = "Moraxyc's NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };
  outputs =
    {
      self,
      flake-parts,
      nixpkgs,
      nixpkgs-stable,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./flake-modules/commands.nix
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      flake = {
        nixosModules = {
          alist = import ./modules/alist.nix;
          gost = import ./modules/gost.nix;
          exloli-next = import ./modules/exloli-next.nix;
          bark-server = import ./modules/bark-server.nix;
        };

        lib = import ./lib;
      };
      perSystem =
        {
          system,
          pkgs,
          inputs',
          ...
        }:
        {
          packages = import ./pkgs/default.nix {
            pkgs = import nixpkgs { inherit system; };
            pkgs-stable = import nixpkgs-stable { inherit system; };
            inherit inputs' system self;
          };
          formatter = pkgs.nixfmt-rfc-style;
        };
    };
}
