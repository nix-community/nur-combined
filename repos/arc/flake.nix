{
  inputs = {
    nixpkgs = {
    };
  };
  outputs = { nixpkgs, self, ... }: let
    forSystems = f: nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed or nixpkgs.lib.systems.supported.hydra (system: f (
      import ./canon.nix { pkgs = nixpkgs.legacyPackages.${system}; }
    ));
  in {
    legacyPackages = forSystems (arc: arc.packages.groups // arc.build // {
      inherit arc;
    });
    packages = forSystems (arc: arc.packages.groups.toplevel);
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
  };
}
