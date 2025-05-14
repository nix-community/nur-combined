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
