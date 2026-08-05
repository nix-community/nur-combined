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

      forEachSystem =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f (
            import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            }
          )
        );
    in
    {
      packages = forEachSystem (
        pkgs:
        let
          lib = pkgs.lib;
          packageFiles = import ./pkgs/by-name.nix {
            inherit lib;
            baseDirectory = ./pkgs/by-name;
          };
        in
        lib.mapAttrs (name: path: pkgs.callPackage path { }) packageFiles
      );

      overlays.default =
        final: prev:
        let
          lib = final.lib;
          packageFiles = import ./pkgs/by-name.nix {
            inherit lib;
            baseDirectory = ./pkgs/by-name;
          };
        in
        lib.mapAttrs (name: path: final.callPackage path { }) packageFiles;

      homeModules.freqtrade-setup = import ./modules/freqtrade-setup.nix;

      formatter = forEachSystem (pkgs: pkgs.nixfmt-rfc-style);
    };
}
