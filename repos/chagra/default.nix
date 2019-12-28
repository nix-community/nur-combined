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


  #Overrides
  ncmpcpp = import ./pkgs/overrides/ncmpcpp.nix;
  neomutt = import ./pkgs/overrides/neomutt.nix;
  notmuch = import ./pkgs/overrides/notmuch.nix;
  vimCustom = import ./pkgs/overrides/vim.nix;
  zathura-poppler-only = pkgs.callPackage ./pkgs/overrides/zathurapoppler.nix { };
}
