{
  description = "xeals's flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      inherit (flake-utils.lib) defaultSystems flattenTree;
      inherit (nixpkgs.lib.attrsets) filterAttrs genAttrs mapAttrs;
    in
    {
      nixosModules = mapAttrs (_: path: import path) (import ./modules);
      overlay = final: prev: {
        xeals = nixpkgs.lib.composeExtensions self.overlays.pkgs;
      };
      overlays = import ./overlays // {
        pkgs = final: prev: import ./pkgs/top-level/all-packages.nix { pkgs = prev; };
      };
      packages = genAttrs defaultSystems
        (system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
            xPkgs = import ./pkgs/top-level/all-packages.nix { inherit pkgs; };
          in
          filterAttrs
            (attr: drv:
              builtins.elem system drv.meta.platforms or [ ])
            xPkgs
        );
    };
}
