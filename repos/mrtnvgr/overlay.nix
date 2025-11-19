self: super:
let
  nameValuePair = n: v: { name = n; value = v; };
  nurAttrs = import ./default.nix { pkgs = super; };

in
builtins.listToAttrs
  (map (n: nameValuePair n nurAttrs.${n})
    (builtins.attrNames nurAttrs))
