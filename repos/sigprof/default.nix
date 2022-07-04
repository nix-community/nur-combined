# This file is the main entry point for NUR.  It should return a set of Nix
# derivations and optionally the special attributes:
#
# - `lib` - a set of Nix functions;
# - `modules` - a set of NixOS modules;
# - `overlays` - a set of Nix package overlays.
#
# The only argument is `pkgs`, through which the user of the repository should
# provide a configured instance of Nixpkgs.
#
{pkgs ? import <nixpkgs> {}}: let
  self = import ./nur.nix {inherit pkgs;};
in
  self.nurPackages.${pkgs.system}
  // {
    inherit (self) lib;
  }
