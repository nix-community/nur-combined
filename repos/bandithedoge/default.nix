{
  pkgs ? import <nixpkgs> { },
  ...
}:
let
  all = import ./all.nix { inherit pkgs; };

  concat = pkgs.lib.concatStringsSep ".";
in
builtins.foldl' pkgs.lib.recursiveUpdate all [
  (pkgs.lib.mapAttrsRecursive (
    old: new:
    pkgs.lib.warn "${concat old} has been renamed to ${concat new}" (pkgs.lib.attrByPath new null all)
  ) (import ./_renamed.nix))

  (pkgs.lib.mapAttrsRecursive (
    old: new:
    pkgs.lib.warn "${concat old} is available in nixpkgs as ${concat new}" (
      pkgs.lib.attrByPath new null pkgs
    )
  ) (import ./_upstreamed.nix { inherit (pkgs) lib; }))

  (pkgs.lib.updateManyAttrsByPath (builtins.map (path: {
    inherit path;
    update = _: throw "${concat path} has been removed";
  }) (import ./_removed.nix)) { })
]
