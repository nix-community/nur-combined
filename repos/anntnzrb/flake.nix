{
  description = "annt's nurpkgs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default/main";
  };

  outputs = { self, nixpkgs, systems }:
    let
      lib = nixpkgs.lib;
      forAllSystems = f: lib.genAttrs (import systems) (system: f system);
    in
    {
      legacyPackages = forAllSystems (system: import ./default.nix {
        pkgs = import nixpkgs { inherit system; };
      });
      packages = forAllSystems (system: lib.filterAttrs (_: v: lib.isDerivation v) self.legacyPackages.${system});
    };
}
