# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{
  pkgs ? import <nixpkgs> {},
  # The dfmic checkout the package builds, when it comes from somewhere other
  # than the pinned tarball (the flake passes its `dfmic` input here).
  dfmicSrc ? null,
}: {
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib {inherit pkgs;}; # functions
  # The NixOS module. A set of modules, as NUR expects, so
  # `nixpkgs-nur.modules.dfmic` works as well as a plain `imports`.
  modules = {
    dfmic = import ./modules/dfmic.nix;
  };

  example-package = pkgs.callPackage ./pkgs/example-package {};
  ez = pkgs.callPackage ./pkgs/ez {};
  wisdom-tree = pkgs.callPackage ./pkgs/wisdom-tree {};
  nohang = pkgs.callPackage ./pkgs/nohang {};
  blue-screen-of-life-grub = pkgs.callPackage ./pkgs/blue-screen-of-life-grub {};
  redlib = pkgs.callPackage ./pkgs/redlib {};
  rbonsai = pkgs.callPackage ./pkgs/rbonsai {};
  noto-fonts-emoji-blob-bin = pkgs.callPackage ./pkgs/blobmoji {};
  clockface-font = pkgs.callPackage ./pkgs/clockface-font {};
  dfmic = pkgs.callPackage ./pkgs/dfmic (
    if dfmicSrc == null
    then {}
    else {inherit dfmicSrc;}
  );
}
