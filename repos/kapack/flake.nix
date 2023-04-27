{
  description = " My personal NUR repository";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs?ref=22.11";
  };
  outputs = { self, nixpkgs, flake-utils }:
    let
      systems = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
      ];
      inherit (flake-utils.lib) eachSystem filterPackages;

    in eachSystem systems (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowBroken = true; # FIXME
        };
      in {
        packages = (filterPackages system (import ./nur.nix { inherit pkgs; }));
        lib = import ./lib { inherit pkgs; };
      }) // {
        nixosModules =
          builtins.mapAttrs (name: path: import path) (import ./modules);
        overlay = import ./overlay.nix;
      };
}
