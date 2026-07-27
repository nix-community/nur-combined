{ pkgs }:
let
  all = import ./all.nix { inherit pkgs; };
  lib = import ./lib.nix { inherit (pkgs) lib; };
in
builtins.filter (
  path:
  let
    eval = builtins.tryEval (pkgs.lib.hasAttrByPath path pkgs);
  in
  if eval.success then
    let
      ours = pkgs.lib.attrByPath path [ ] all;
    in
    if (pkgs.lib.hasAttr "_ignoreDupe" ours && ours._ignoreDupe) then false else eval.value
  else
    false
) (lib.drvPaths all)
