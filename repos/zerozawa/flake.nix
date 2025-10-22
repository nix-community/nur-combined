{
  description = "zerozawa's NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs = {
    self,
    nixpkgs,
  }: let
    inherit (nixpkgs) lib;
    forAllSystems = lib.genAttrs lib.systems.flakeExposed;
  in {
    legacyPackages = forAllSystems (system:
      import ./default.nix {
        pkgs = import nixpkgs {inherit system;};
      });
    packages = forAllSystems (system: lib.filterAttrs (n: v: lib.elem system ((v.meta or {platforms = lib.platforms.none;}).platforms or lib.platforms.none)) (lib.filterAttrs (_: v: lib.isDerivation v) self.legacyPackages.${system}));
  };
}
