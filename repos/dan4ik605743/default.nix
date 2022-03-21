{ pkgs ? import <nixpkgs> { } }:

{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  compton = pkgs.callPackage ./pkgs/compton { };
  bitmap-fonts = pkgs.callPackage ./pkgs/bitmap-fonts { };
  i3lock-color = pkgs.callPackage ./pkgs/i3lock-color { };
  sddm-chili = pkgs.callPackage ./pkgs/sddm-chili { };
  htop-solarized = pkgs.callPackage ./pkgs/htop-solarized { };
  simp1e-cursors = pkgs.callPackage ./pkgs/simp1e-curosrs { };
}
