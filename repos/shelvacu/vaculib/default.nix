{ lib, ... }@passedArgs:
let
  args = passedArgs // {
    inherit vaculib;
  };
  directoryListing = builtins.removeAttrs (builtins.readDir ./.) [ "default.nix" ];
  filePaths = lib.mapAttrsToList (
    k: v:
    assert v == "regular";
    ./${k}
  ) directoryListing;
  functionSets = map (path: import path args) filePaths;
  mergeVals =
    name: a: b:
    if (builtins.isAttrs a) && (builtins.isAttrs b) then
      mergeAttrs a b
    else
      lib.throw "duplicate attr ${name}";
  mergeAttrs =
    a: b:
    builtins.mapAttrs (name: val:
      if (a ? name) && (b ? name) then
        mergeVals name a.${name} b.${name}
      else
        val
    ) (a // b);
  vaculib = lib.foldr mergeAttrs { } functionSets;
in
vaculib
