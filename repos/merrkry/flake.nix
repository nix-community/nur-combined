{
  description = "My personal NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs =
    { self, nixpkgs }:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
    in
    {
      legacyPackages = forAllSystems (
        system:
        import ./default.nix {
          pkgs = import nixpkgs { inherit system; };
        }
      );
      packages = forAllSystems (
        system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system}
      );
      buildJobs = forAllSystems (
        system:
        nixpkgs.lib.filterAttrs (
          _: package:
          !(package.meta.broken or false)
          && (package.meta.hydraPlatforms or package.meta.platforms or [ ]) != [ ]
        ) self.packages.${system}
      );
      apps = forAllSystems (system: {
        nix-fast-build = {
          type = "app";
          program = "${nixpkgs.legacyPackages.${system}.nix-fast-build}/bin/nix-fast-build";
        };
      });
    };
}
