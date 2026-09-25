{
  description = "My personal NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
      legacyPackages = forAllSystems (system: import ./default.nix {
        pkgs = import nixpkgs { inherit system; };
      });
      packages = forAllSystems (system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system});

      nixosModules.autolock = ./modules/autolock.nix;
      homeManagerModules.autolock = ./modules/autolock.nix;

      devShells = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; };
        in {
          default = pkgs.mkShell {
            name = "nur";

            nativeBuildInputs = with pkgs; [
              # Nix
              nil
              nix-melt
              nix-output-monitor
              nix-tree
              nixpkgs-fmt

              # Shell
              shellcheck
              shfmt

              # GitHub Actions
              act
              actionlint

              # Misc
              jq
              pre-commit
              just
              fzf
            ];

            shellHook = ''
              if [ -f .pre-commit-config.yaml ] && ! grep -q "pre-commit" .git/hooks/pre-commit 2>/dev/null; then
                pre-commit install
              fi
            '';
          };
        });
    };
}
