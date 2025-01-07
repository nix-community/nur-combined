{
  description = "My personal NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };
  outputs =
    inputs@{ self, nixpkgs, ... }:
    let
      lib = nixpkgs.lib;
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      forAllSystems = f: lib.genAttrs systems (system: f system);
      forAllBranches = f: lib.genAttrs (builtins.attrNames inputs) (branch: f inputs.${branch});
    in
    {
      legacyPackages = forAllSystems (
        system:
        import ./default.nix {
          pkgs = import nixpkgs { inherit system; };
        }
      );
      packages = forAllSystems (
        system: lib.filterAttrs (_: v: lib.isDerivation v) self.legacyPackages.${system} // {
          ci = forAllBranches (
            nixpkgs: let
              pkgs = import nixpkgs { inherit system; };
            in {
              nixpkgs-version = pkgs.writeShellScriptBin "nixpkgs-version" ''
                echo "${pkgs.lib.version}"
              '';
            }
          );
        }
      );
      formatter = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        pkgs.nixfmt-rfc-style
      );
      inherit (import ./modules) nixosModules darwinModules homeManagerModules;
    };
}
