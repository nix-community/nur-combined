{
  description = "My personal NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        # x86_64-darwin is intentionally omitted: nixpkgs-unstable has
        # dropped support for it (see the 26.11 release notes), even though
        # upstream still publishes an omp-darwin-x64 binary.
        "aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems f;
    in
    {
      overlays.default = import ./overlays;

      legacyPackages = forAllSystems (
        system:
        import ./default.nix {
          pkgs = nixpkgs.legacyPackages.${system};
        }
      );

      packages = forAllSystems (system: {
        inherit (self.legacyPackages.${system}) omp;
        default = self.legacyPackages.${system}.omp;
      });

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              nix-prefetch-scripts
              jq
              nixfmt-tree
              statix
              deadnix
            ];
          };
        }
      );

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);

      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.omp}/bin/omp";
        };
      });
    };
}
