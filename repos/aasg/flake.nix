{
  description = "aasg's Nix expressions";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };
  outputs = { self, flake-utils, nixpkgs }:
    let
      inherit (flake-utils.lib) defaultSystems flattenTree;
      inherit (nixpkgs.lib.attrsets) filterAttrs genAttrs mapAttrs;
      inherit (nixpkgs.lib.strings) hasPrefix hasSuffix;
      inherit (nixpkgs.lib.trivial) id flip pipe;
    in
    {
      lib = import ./lib { inherit (nixpkgs) lib; };
      packages = genAttrs defaultSystems
        (system: pipe (import ./. { pkgs = nixpkgs.legacyPackages.${system}; }) [
          # Remove non–package attributes.
          (flip builtins.removeAttrs [ "lib" "modules" "overlays" "packageSets" ])
          # Filter out linuxPackages before it gets evaluated.
          (if ! hasSuffix "linux" system
          then filterAttrs (attr: drv: ! hasPrefix "linuxPackages" attr)
          else id)
          # Flatten package sets.
          flattenTree
          # Remove packages not compatible with this system.
          (filterAttrs (attr: drv: builtins.elem system drv.meta.platforms))
        ]);
      nixosModules = mapAttrs (name: path: import path) (import ./modules);
      overlays = {
        pkgs = import ./pkgs/overlay.nix;
        patches = import ./patches/overlay.nix;
      };
      overlay = final: prev:
        nixpkgs.lib.composeExtensions self.overlays.pkgs self.overlays.patches final prev;
    };
}
