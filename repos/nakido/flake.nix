{
  description = "NUR package repository by nakido";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-compat.url = "./dependencies/flake-compat-ff81ac966bb2cae68946d5ed5fc4994f96d0ffec"; # github:NixOS/flake-compat/v1.1.0
    flake-compat.flake = false;
  };

  outputs =
    { self, ... }@inputs:
    with inputs;
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
    in
    {
      lib = import ./lib { inherit (nixpkgs) lib; };

      packages = forAllSystems (
        system:
        builtins.listToAttrs (
          map (file: {
            name = self.lib.getFilenameNoSuffix file;
            value = nixpkgs.legacyPackages.${system}.callPackage file { };
          }) (self.lib.globPackages ./pkgs)
        )
      );

      legacyPackages = forAllSystems (
        system:
        self.packages.${system}
        // {
          # The `lib`, `modules`, and `overlays` names are special
          # modules = import ./modules; # NixOS modules
          # overlays = import ./overlays; # nixpkgs overlays
          # example-package = pkgs.callPackage ./pkgs/example-package { };
        }
      );
    };
}