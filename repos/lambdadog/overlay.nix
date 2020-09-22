self: super:

# TODO: Handle ./overlays, I imagine we'll have to apply them then
# apply our own overlay, but I'm not sure if there's a better
# abstraction existing already in nixpkgs for this transformation.

# We can't use callPackage here because it will infinitely recurse
let overlay-lib = import ./lib { pkgs = super; };
    overlay-pkgs = import ./pkgs { pkgs = super; };
in {
  lib = super.lib // overlay-lib;
} // overlay-pkgs
