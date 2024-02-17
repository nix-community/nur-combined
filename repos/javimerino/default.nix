{ pkgs ? import <nixpkgs> { } }:

let
  # Only add pkgs when NUR is imported with pkgs. Otherwise, when used
  # as nur-no-pkgs, only modules and overlays are defined and no pkgs
  # are evaluated.
  my_pkgs =
    if pkgs != null then
      (import ./pkgs { inherit pkgs; })
    else
      { };
in
{
  # The `lib`, `modules`, and `overlays` names are special
  #lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  #overlays = import ./overlays; # nixpkgs overlays
} // my_pkgs
