{
  description = "plabadens' NUR reporsitory";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, flake-utils, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        nur-packages = import ./default.nix { inherit pkgs; };
      in
      rec {
        legacyPackages = pkgs.lib.filterAttrs
          (n: v: !(builtins.elem n [ "lib" "modules" "overlays" ]))
          nur-packages;

        packages = flake-utils.lib.flattenTree legacyPackages;
      });
}
