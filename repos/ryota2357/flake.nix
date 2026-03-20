{
  description = "My personal NUR repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

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

      overlays.default = import ./overlay.nix;

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              nil
              nvfetcher
            ];
          };
        }
      );

      formatter = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        pkgs.writeShellApplication {
          name = "format";
          runtimeInputs = [ pkgs.nixfmt ];
          text = ''
            run() {
              echo "$*"
              "$@"
            }
            if [ -f "flake.nix" ]; then
              run nixfmt flake.nix
            fi
            if [ -d "pkgs" ]; then
              for file in pkgs/**/*.nix; do
                run nixfmt "$file"
              done
            fi
            echo "complete!"
          '';
        }
      );
    };
}
