{ pkgs ? import <nixpkgs> { } }:

{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  Responder = pkgs.callPackage ./pkgs/Responder { };
  BloodHound = pkgs.callPackage ./pkgs/BloodHound { };
  bloodhound-python = pkgs.callPackage ./pkgs/bloodhound-python { };
  seclists = pkgs.callPackage ./pkgs/seclists { };
  psudohash = pkgs.callPackage ./pkgs/psudohash { };
  ADCSKiller = pkgs.callPackage ./pkgs/ADCSKiller { };
  polenum = pkgs.callPackage ./pkgs/polenum { };
  maltego = pkgs.callPackage ./pkgs/maltego { };
}
