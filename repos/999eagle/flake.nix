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
      isReserved = n: n == "lib" || n == "overlays" || n == "modules";
      skipBuild = n: isReserved n || n == "openmoji";
      isBuildable = p: let
        licenseFromMeta = p.meta.license or [];
        licenseList =
          if builtins.isList licenseFromMeta
          then licenseFromMeta
          else [licenseFromMeta];
      in
        !(p.meta.broken or false) && builtins.all (license: license.free or true) licenseList;
      isCacheable = p: !(p.preferLocalBuild or false);
    in {
      packages = lib.filterAttrs (name: value: lib.isDerivation value) packages;
      legacyPackages = lib.filterAttrs (name: value: ! lib.isDerivation value) packages;
      checks = lib.filterAttrs (name: value: !(skipBuild name) && lib.isDerivation value && isBuildable value && isCacheable value) packages;
    })
    // {
      overlays.default = import ./overlay.nix;
      hydraJobs = lib.genAttrs hydraSystems (system: self.packages.${system});
    };
}
