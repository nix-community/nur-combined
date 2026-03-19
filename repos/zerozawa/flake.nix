{
  description = "zerozawa's NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  nixConfig = {
    substituters = [
      "https://zerozawa.cachix.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "zerozawa.cachix.org-1:9jPl+Xq6S4va32gPNJXTApDafDUwa5zjgFX65QfJ1CQ="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
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
