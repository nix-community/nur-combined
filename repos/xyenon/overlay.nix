# You can use this file as a nixpkgs overlay. This is useful in the
# case where you don't want to add the whole NUR namespace to your
# configuration.

self: super:
let
  isReserved = n: n == "lib" || n == "overlays" || n == "modules" || n == "hmModules";
  nameValuePair = n: v: { name = n; value = v; };
  nurAttrs = import ./default.nix { pkgs = super; };

in
builtins.listToAttrs
  (map
    (n: nameValuePair n (
      let v = nurAttrs.${n}; in
      if (!super.lib.isDerivation v) && (builtins.isAttrs v) && (super ? ${n})
      then (super.${n} // v) else v
    ))
    (builtins.filter (n: !isReserved n)
      (builtins.attrNames nurAttrs)))
