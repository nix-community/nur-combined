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

    git-hooks = {
      type = "github";
      owner = "cachix";
      repo = "git-hooks.nix";
      ref = "master";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs = { self, futils, nixpkgs, git-hooks }:
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

        pre-commit = git-hooks.lib.${system}.run {
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
            inputsFrom = [
              self.packages.${system}.project
            ];

            packages = with pkgs; [
              rust-analyzer
              self.checks.${system}.pre-commit.enabledPackages
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
