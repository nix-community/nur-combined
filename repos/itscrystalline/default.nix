# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{pkgs ? import <nixpkgs> {}}: {
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib {inherit pkgs;}; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  app2nix = pkgs.callPackage ./pkgs/app2unit {};
  occasion = pkgs.callPackage ./pkgs/occasion {};
  sipa-th-fonts = pkgs.callPackage ./pkgs/sipa-th-fonts {};
  hass-localtuya = pkgs.callPackage ./pkgs/hass-localtuya {};
  ha_tuya_ble = pkgs.callPackage ./pkgs/ha_tuya_ble {};
  irony-mod-manager = pkgs.callPackage ./pkgs/irony-mod-manager {};
  oracle-cloud-agent = pkgs.callPackage ./pkgs/oracle-cloud-agent {};
  oci-utils = pkgs.callPackage ./pkgs/oci-utils {};
  oci-image-migrate = pkgs.callPackage ./pkgs/oci-image-migrate {};
}
