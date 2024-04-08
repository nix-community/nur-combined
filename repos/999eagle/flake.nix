{
  description = "My personal NUR repository";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };
  outputs = {
    self,
    nixpkgs,
    utils,
  }: let
    inherit (nixpkgs) lib;
    hydraSystems = ["x86_64-linux" "aarch64-linux"];
  in
    utils.lib.eachSystem hydraSystems (system: let
      pkgs = import nixpkgs {inherit system;};
      packages = lib.filterAttrs (name: value: builtins.elem system (value.meta.platforms or [system])) (import ./default.nix {inherit pkgs;});
    in {
      packages = lib.filterAttrs (name: value: lib.isDerivation value) packages;
      legacyPackages = lib.filterAttrs (name: value: ! lib.isDerivation value) packages;
    })
    // {
      overlays.default = import ./overlay.nix;
      hydraJobs = lib.genAttrs hydraSystems (system: self.packages.${system});
    };
}
