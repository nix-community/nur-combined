{
  callPackage,
  ocamlPackages,
  ...
}:

let
  components = callPackage ./components/package.nix { inherit ocamlPackages; };
in
components.isabelle
