{
  description = "A Python project";

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
          project = with final; python3.pkgs.buildPythonApplication {
            pname = "project";
            version = (final.lib.importTOML ./pyproject.toml).project.version;
            pyproject = true;

            src = self;

            build-system = with python3.pkgs; [ setuptools ];

            pythonImportsCheck = [ "project" ];

            meta = with lib; {
              description = "A Python project";
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
            mypy = {
              enable = true;
            };

            nixpkgs-fmt = {
              enable = true;
            };

            ruff = {
              enable = true;
            };

            ruff-format = {
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
              uv
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
