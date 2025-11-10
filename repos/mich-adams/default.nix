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
    #linux-postmarketos-allwinner = pkgs.callPackage ./pkgs/linux-postmarketos-allwinner.nix { };
    stardrop = pkgs.callPackage ./pkgs/stardrop { };
    
    #crust-firmware = pkgs.callPackage ./pkgs/crust-firmware.nix { };
}
