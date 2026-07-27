{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
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
              inputs.rust-overlay.overlays.default
            ];
          };

          treefmt = {
            projectRootFile = "flake.nix";
            settings.global.excludes = [ ];
            programs = {
              rustfmt.enable = true;
            };
          };

          devShells.default =
            let
              rust-toolchain = pkgs.rust-bin.stable.default.override {
                extensions = [
                  "rust-src"
                  "rust-analyzer"
                ];
              };
            in
            pkgs.mkShell {
              packages =
                with pkgs;
                [
                  # Rust toolchain
                  openssl
                  pkg-config
                  # rustPlatform.bindgenHook
                ]
                ++ rust-toolchain;
            };
        };
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    };
}
