{
  description = "My personal NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs =
    { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        legacyPackages = import ./default.nix { inherit pkgs; };
      in
      {
        legacyPackages = legacyPackages;
        packages = nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) legacyPackages;
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nix
            git
          ] ++ (with legacyPackages; [
            zmx
            brew2nur
          ]);
        };
      }
    );
}
