# This file is an alternate entry point for NUR if you want to use the
# repository as a simple Nixpkgs overlay instead of going through the central
# NUR repo with the corresponding namespacing.
#
# Note that the usage of this overlay may result in some problems if the
# packages defined in this repository actually have the same names as packages
# from Nixpkgs or any other source.  The overlay also does not provide access
# to other types of the content that may be present in the repository, such as
# custom Nix functions, NixOS modules, or even other package overlays.
#
final: prev: let
  self = import ./nur.nix {pkgs = prev;};
in
  self.nurPackages.${prev.system}
