{
  description = "My personal NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };
  outputs = inputs @ {
    self,
    flake-parts,
    nixpkgs,
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = nixpkgs.lib.systems.flakeExposed;

      imports = [
        ({inputs, ...}: {
          perSystem = {system, ...}: {
            _module.args = {
              pkgs = import inputs.nixpkgs {
                inherit system;
              };
            };
          };
        })
      ];

      flake = {
        templates = {
          mise = {
            path = ./templates/mise;
            description = "A flake for projects managed with mise";
            welcomeText = ''
              # Getting started
              ## without direnv
              - Run `nix develop`
              ## with direnv
              - Add "use flake" to .enrc - `echo "use flake" >> .envrc`
              - Run `direnv allow`
            '';
          };
        };
      };

      perSystem = {
        pkgs,
        system,
        ...
      }: {
        packages = import ./default.nix {inherit pkgs;};
        formatter = pkgs.alejandra;
      };
    };
}
