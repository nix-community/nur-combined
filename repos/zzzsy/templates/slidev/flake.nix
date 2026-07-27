{
  description = "Slidev presentation development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {

      perSystem =
        { pkgs, ... }:
        {
          devShells.default = pkgs.mkShell {
            buildInputs = with pkgs; [
              nodejs_22
              pnpm
              playwright-driver
            ];
            shellHook = ''
              echo "Node.js + pnpm development environment with Slidev"
              echo "Node.js version: $(node --version)"
              echo "pnpm version: $(pnpm --version)"

              # Ensure playwright browsers are available
              export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
              echo "if want to create a new Slidev project, run:"
              echo "pnpm create slidev"
              echo "if you have an existing Slidev project, run 'pnpm install' to install dependencies"
            '';

            packages = [
              # todo
            ];
          };
        };
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    };
}
