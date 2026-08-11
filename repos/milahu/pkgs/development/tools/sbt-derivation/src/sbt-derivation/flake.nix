{
  description = "Nix interop for sbt projects";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    {
      overlays.default = import ./overlay.nix;
      lib.mkSbtDerivation = import ./default.nix;

      templates.cli-app = {
        path = ./templates/cli-app;
        description = "Nix flake template for Scala projects";
      };
    }
    // (flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages."${system}";
      testDependencies = with pkgs; [gnused gron nix-prefetch];
    in {
      mkSbtDerivation = import ./lib/bootstrap.nix pkgs;

      devShells.default = pkgs.mkShell {
        buildInputs = testDependencies;
      };

      packages.test-runner = pkgs.writeShellScriptBin "test-runner" ''
        set -eu

        export PATH=${pkgs.lib.makeBinPath testDependencies}":$PATH"
        # necessary for nix-prefetch and the sbt-derivation projects
        export NIX_PATH='nixpkgs=${pkgs.path}'

        repo="$1"
        shift

        "$repo/tests/populate-version-matrix.sh" "$repo/tests/version-matrix.bats"
        exec "$repo/tests/bats/bin/bats" "$@"
      '';
    }));
}
