{ pkgs ? import <nixpkgs> { } }:

let
  ci = import ./ci.nix { inherit pkgs; };
  filterFree = pkg: pkg.meta.license.free or true;
  freePkgs = builtins.filter filterFree ci.buildPkgs;

  listToJobset = prefix: list: builtins.listToAttrs (
    builtins.genList (i:
      let
        pkg = builtins.elemAt list i;
        name = "${prefix}-${pkg.name}";
      in { inherit name; value = pkg; }
    ) (builtins.length list)
  );
in
{
  release-pkgs = listToJobset "free" freePkgs;
}
