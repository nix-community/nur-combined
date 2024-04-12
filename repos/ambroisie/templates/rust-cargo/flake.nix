{
  description = "A Rust project";

  inputs = {
    futils = {
      type = "github";
      owner = "numtide";
      repo = "flake-utils";
      ref = "main";
    };

    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixos-unstable";
    };

    pre-commit-hooks = {
      type = "github";
      owner = "cachix";
      repo = "pre-commit-hooks.nix";
      ref = "master";
      inputs = {
        flake-utils.follows = "futils";
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs = { self, futils, nixpkgs, pre-commit-hooks }:
    {
      overlays = {
        default = final: _prev: {
          project = with final; rustPlatform.buildRustPackage {
            pname = "project";
            version = (final.lib.importTOML ./Cargo.toml).package.version;

            src = self;

            cargoLock = {
              lockFile = "${self}/Cargo.lock";
            };

            meta = with lib; {
              description = "A Rust project";
              homepage = "https://git.belanyi.fr/ambroisie/project";
              license = licenses.mit;
              maintainers = with maintainers; [ ambroisie ];
            };
          };
        };
      };
    } // futils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            self.overlays.default
          ];
        };

        pre-commit = pre-commit-hooks.lib.${system}.run {
          src = self;

          hooks = {
            clippy = {
              enable = true;
              settings = {
                denyWarnings = true;
              };
            };

            nixpkgs-fmt = {
              enable = true;
            };

            rustfmt = {
              enable = true;
            };
          };
        };
      in
      {
        checks = {
          inherit (self.packages.${system}) project;
        };

        devShells = {
          default = pkgs.mkShell {
            inputsFrom = with self.packages.${system}; [
              project
            ];

            packages = with pkgs; [
              clippy
              rust-analyzer
              rustfmt
            ];

            RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";

            inherit (pre-commit) shellHook;
          };
        };

        packages = futils.lib.flattenTree {
          default = pkgs.project;
          inherit (pkgs) project;
        };
      });
}
