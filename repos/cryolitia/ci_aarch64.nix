# This file provides all the buildable and cacheable packages and
# package outputs in your package set. These are what gets built by CI,
# so if you correctly mark packages as
#
# - broken (using `meta.broken`),
# - unfree (using `meta.license.free`), and
# - locally built (using `preferLocalBuild`)
#
# then your CI will be able to build and cache only those packages for
# which this is possible.

{ pkgs ? import <nixpkgs> { 
    config = {
      allowUnfree = true;
    }; 
    crossSystem = {
      config = "aarch64-unknown-linux-gnu";
    };
  } 
}:

./ci.nix { inherit pkgs; }
