{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> { inherit system; },
}:
{
  bundlers = import ./bundlers {
    inherit system pkgs;
  };

  lib = import ./libs {
    inherit system pkgs;
  };

  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays
}
// pkgs.lib.filterAttrs (_: pkg: if builtins.hasAttr "ifd" pkg then !pkg.ifd else true) (
  import ./packages {
    inherit system pkgs;
  }
)
