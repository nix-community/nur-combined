{
  description = "A Nix-flake-based Hugo template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {

      perSystem =
        { pkgs, ... }:
        {
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              hugo
              dart-sass
            ];
          };
        };
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    };
}
