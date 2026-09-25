{
  pkgs ? import <nixpkgs> { },
}:

let
  isReserved = n: n == "overlays" || n == "modules";
  isDerivation = p: builtins.isAttrs p && p ? type && p.type == "derivation";

  nurAttrs = import ./default.nix { inherit pkgs; };

  buildPkgs = builtins.listToAttrs (
    builtins.filter (x: x != null) (
      map (
        n:
        if !isReserved n && isDerivation nurAttrs.${n} then
          {
            name = n;
            value = nurAttrs.${n};
          }
        else
          null
      ) (builtins.attrNames nurAttrs)
    )
  );

in
buildPkgs
