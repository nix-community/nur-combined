{
  description = "Koleksi custom Nix packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      lib = nixpkgs.lib;

      pkgsPath = ./pkgs;

      packageDirs = lib.filterAttrs (name: type: type == "directory") (builtins.readDir pkgsPath);

      packageNames = builtins.attrNames packageDirs;
    in
    {
      packages.${system} = lib.genAttrs packageNames (
        name: pkgs.callPackage (pkgsPath + "/${name}/default.nix") { }
      );
      homeModules.freqtrade-setup = import ./modules/freqtrade-setup.nix;
    };
}
