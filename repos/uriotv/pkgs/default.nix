# Package registry: add pkgs/<attribute>/default.nix and it is exported everywhere.
# No per-package list in the NUR entry point, flake, overlay or CI is needed.
{ pkgs }:
let
  names = import ./registry.nix { packageDirectory = ./.; };
in
assert builtins.all (
  name:
  builtins.match "[A-Za-z0-9][A-Za-z0-9._+-]*" name != null
  && !(builtins.elem name [
    "lib"
    "modules"
    "overlays"
    "rimsort"
  ])
) names;
builtins.listToAttrs (
  map (name: {
    inherit name;
    value = pkgs.callPackage (./. + "/${name}") { };
  }) names
)
