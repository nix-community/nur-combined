{ pkgs ? import <nixpkgs> {} }:

{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  #Actual Packages
  ueberzug = pkgs.callPackage ./pkgs/ueberzug { };
  nudoku = pkgs.callPackage ./pkgs/nudoku { };
  swayblocks = pkgs.callPackage ./pkgs/swayblocks { };
  cboard = pkgs.callPackage ./pkgs/cboard { };
  ripcord = pkgs.callPackage ./pkgs/ripcord { };
  ydotool = pkgs.callPackage ./pkgs/ydotool { };
  compton-tryone = pkgs.callPackage ./pkgs/compton-tryone { };


  #Overrides that Travis CI will build so I don't have to
  vimCustom = pkgs.callPackage ./pkgs/overrides/vim.nix { };
  zathura-poppler-only = pkgs.callPackage ./pkgs/overrides/zathurapoppler.nix { };
}
