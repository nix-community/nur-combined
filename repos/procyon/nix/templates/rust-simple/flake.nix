{
  description = "Rust Project [Simple Template]";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];

      imports = with inputs; [ treefmt-nix.flakeModule ];

      perSystem = { system, self', inputs', config, pkgs, lib, ... }:
        let
          cargoToml = builtins.fromTOML (builtins.readFile ./Cargo.toml);
          buildInputs = lib.attrValues { };
          nativeBuildInputs = lib.attrValues {
            inherit (pkgs)
              lldb
              rustc
              cargo
              clippy
              rustfmt
              rust-analyzer
              ;
          };
        in
        {
          treefmt.config = {
            projectRootFile = "Cargo.toml";
            programs.rustfmt.enable = true;
          };

          packages.default = pkgs.rustPlatform.buildRustPackage {
            src = ./.;
            cargoLock.lockFile = ./Cargo.lock;
            inherit (cargoToml.package) name version;
          };

          devShells.default = pkgs.mkShell {
            RUST_BACKTRACE = 1;
            inherit buildInputs nativeBuildInputs;
            inputsFrom = [ config.treefmt.build.devShell ];
            shellHook = ''
              export RUST_SRC_PATH=${pkgs.rustPlatform.rustLibSrc}
            '';
          };
        };
    };
}
