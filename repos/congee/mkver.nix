{ lib, pkgs, ... }:
let
  tmp = import ./. { inherit pkgs; };
  pkgset = builtins.removeAttrs tmp [ "lib" "modules" "overlays" ];

  eval = k: v: (
    let
      concatnames = set: lib.mapAttrs' (a: b: lib.nameValuePair "${k}.${a}" b) set;
      iscommit = str: builtins.match "([0-9a-z]{40})" str == [ str ];
      normalize = ver: if iscommit ver then builtins.substring 0 8 ver else ver;
    in

    if lib.isDerivation v
    then [{ name = k; version = normalize v.version; url = v.meta.homepage; }]
    else builtins.attrValues (builtins.mapAttrs eval (concatnames v))
  );

  styled = set: { homepage = "[${set.name}](${set.url})"; inherit (set) version; };
  sorted = builtins.sort (a: b: a.homepage < b.homepage);

in
sorted (map styled (lib.flatten (lib.mapAttrsToList eval pkgset)))
