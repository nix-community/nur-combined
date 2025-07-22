{
  pkgs ? import <nixpkgs> { },
}:

{
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # Packages
  vvmd = pkgs.callPackage ./pkgs/vvmd.nix { };
  vvmplayer = pkgs.callPackage ./pkgs/vvmplayer.nix { };
  afterglow-cursors = pkgs.callPackage ./pkgs/afterglow-cursors.nix { };
    #linux-postmarketos-allwinner = pkgs.pkgsCross.aarch64-multiplatform.callPackage ./pkgs/linux-postmarketos-allwinner.nix { };
    #crust-firmware = pkgs.callPackage ./pkgs/crust-firmware.nix { };
}
