# The repository's contents, as NUR reads them: packages, plus the special
# attributes `lib`, `nixosModules`, `homeModules`, `modules` (the older
# name for `nixosModules`) and `overlays`. It must not import <nixpkgs>
# itself (NUR evaluates it with its own); the default only makes
# `nix-build -A <package>` work from a checkout.
{
  pkgs ? import <nixpkgs> { },
}:

{
  # NixOS modules, which NUR offers as nur.repos.iedame.modules.nixos.<name>
  nixosModules = import ./modules;

  jagex-launcher = pkgs.callPackage ./pkgs/jagex-launcher/package.nix { };
  openrsc-launcher = pkgs.callPackage ./pkgs/openrsc-launcher/package.nix { };
}
