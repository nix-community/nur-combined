{ lib }:
let
  vaculib-directoryGrabber = import ./directoryGrabber.nix { inherit lib; };
  args = {
    inherit lib;
    inherit vaculib;
  };
  filePaths = vaculib-directoryGrabber.directoryGrabber ./.;
  functionSets = builtins.mapAttrs (_: path: import path args) filePaths;
  mergeVals =
    name: a: b:
    if (builtins.isAttrs a) && (builtins.isAttrs b) then
      mergeAttrs a b
    else
      lib.throw "duplicate attr ${name}";
  mergeAttrs =
    a: b:
    builtins.mapAttrs (
      name: val: if (a ? name) && (b ? name) then mergeVals name a.${name} b.${name} else val
    ) (a // b);
  removeUnderscoreAttrs = lib.filterAttrs (k: _: (builtins.substring 0 1 k) != "_");
  attrSetsToMerge = lib.pipe functionSets [
    removeUnderscoreAttrs
    (lib.mapAttrsToList (_: v: removeUnderscoreAttrs v))
    (l: l ++ lib.singleton { _unmerged = functionSets; })
  ];
  vaculib = lib.foldr mergeAttrs { } attrSetsToMerge;
in
vaculib
