{
  inputs = {
    nixpkgs = {
    };
  };
  outputs = { nixpkgs, self, ... }: let
    nixlib = nixpkgs.lib;
    forSystems = f: nixlib.genAttrs nixlib.systems.flakeExposed or nixlib.systems.supported.hydra (system: f (
      import ./canon.nix { pkgs = nixpkgs.legacyPackages.${system}; }
    ));
  in {
    legacyPackages = forSystems (arc: arc.packages.groups // arc.build // {
      inherit arc;
    });
    packages = forSystems (arc: nixlib.filterAttrs (name: package:
      name != "recurseForDerivations"
      && package.meta.available or true != false
    ) arc.packages.groups.toplevel);
    devShells = forSystems (arc: arc.shells);
    nixosModules = import ./modules/nixos // {
      default = self.nixosModules;
    };
    homeModules = import ./modules/home // {
      default = self.homeModules;
    };
    modules = import ./modules;
    overlays = import ./overlays // {
      default = self.overlays;
    };
    lib = import ./lib {
      inherit (nixpkgs) lib;
    };
    flakes.config = rec {
      name = "arc";
      packages.namespace = [ name ]; # TODO: this is just to work around a bug, really?
    };
  };
  nixConfig = {
    extra-substituters = [ "https://arc.cachix.org" ];
    extra-trusted-public-keys = [ "arc.cachix.org-1:DZmhclLkB6UO0rc0rBzNpwFbbaeLfyn+fYccuAy7YVY=" ];
  };
}
