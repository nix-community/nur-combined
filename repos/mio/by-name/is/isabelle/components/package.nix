{
  lib,
  callPackage,
  ocamlPackages,
}:

lib.recurseIntoAttrs (callPackage ./components.nix { inherit ocamlPackages; })
