{
  description = "A Nix-flake-based Typst development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.treefmt-nix.flakeModule
      ];

      perSystem =
        { pkgs, ... }:
        {
          treefmt = {
            projectRootFile = "flake.nix";
            settings.global.excludes = [ ];
            programs = {
              typstyle.enable = true;
            };
          };

          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              typst
              tinymist
              pandoc
            ];
          };
        };
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    };
}
