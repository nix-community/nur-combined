{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    zig-overlay.url = "github:mitchellh/zig-overlay";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.treefmt-nix.flakeModule
      ];

      perSystem =
        { pkgs, system, ... }:
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [
              inputs.zig-overlay.overlays.default
            ];
          };

          treefmt = {
            projectRootFile = "flake.nix";
            settings.global.excludes = [ ];
            programs = {
              zig.enable = true;
            };
          };

          devShells.default =
            let
              deps = with pkgs; [
                gcc
                zigpkgs.default
                zls
              ];
            in
            pkgs.mkShell {
              packages = deps;
              shellHook = ''
                export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.lib.makeLibraryPath deps}
                echo "Zig version: $(zig version)"
              '';
            };
        };
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    };
}
