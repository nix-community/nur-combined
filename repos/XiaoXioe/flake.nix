{
  description = "Koleksi custom Nix packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forEachSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f (import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      }));
    in
    {
      packages = forEachSystem (pkgs:
        let
          lib = pkgs.lib;
          pkgsPath = ./pkgs;
          packageDirs = lib.filterAttrs (name: type: type == "directory") (builtins.readDir pkgsPath);
          packageNames = builtins.attrNames packageDirs;
        in
        lib.genAttrs packageNames (
          name: pkgs.callPackage (pkgsPath + "/${name}/default.nix") { }
        )
      );

      homeModules.freqtrade-setup = import ./modules/freqtrade-setup.nix;
    };
}
