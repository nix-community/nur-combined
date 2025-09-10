{
  description = "My personal NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs = { self, nixpkgs }:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
    in
    {
      legacyPackages = forAllSystems (system: import ./default.nix {
        pkgs = import nixpkgs { inherit system; };
      });
      overlays.default = import ./overlay.nix;
      packages = forAllSystems (system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system});
devShells = forAllSystems (system: {
        default =
          let
            pkgs = import nixpkgs { inherit system; };

          in
          pkgs.mkShellNoCC {
            packages = [
              pkgs.nvfetcher
            ];
          };
      });

    };
}
