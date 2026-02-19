{
  description = "A C++ project";

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
          project = with final; stdenv.mkDerivation {
            pname = "project";
            version = "0.0.0";

            src = self;

            nativeBuildInputs = with pkgs; [
              meson
              ninja
              pkg-config
            ];

            checkInputs = with pkgs; [
              gtest
            ];

            doCheck = true;

            meta = with lib; {
              description = "A C++ project";
              homepage = "https://git.belanyi.fr/ambroisie/project";
              license = licenses.mit;
              maintainers = with maintainers; [ ambroisie ];
              platforms = platforms.unix;
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
            nixpkgs-fmt = {
              enable = true;
            };

            clang-format = {
              enable = true;
            };
          };
        };
      in
      {
        checks = {
          inherit (self.packages.${system}) project;

          inherit pre-commit;
        };

        devShells = {
          default = pkgs.mkShell {
            inputsFrom = [
              self.packages.${system}.project
            ];

            packages = with pkgs; [
              self.checks.${system}.pre-commit.enabledPackages
            ];

            inherit (pre-commit) shellHook;
          };
        };

        packages = futils.lib.flattenTree {
          default = pkgs.project;
          inherit (pkgs) project;
        };
      });
}
