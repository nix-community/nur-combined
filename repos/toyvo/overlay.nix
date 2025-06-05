# You can use this file as a nixpkgs overlay. This is useful in the
# case where you don't want to add the whole NUR namespace to your
# configuration.
self: super:
let
  nurAttrs = import ./default.nix { pkgs = super; };
in
with nurAttrs.lib;
builtins.listToAttrs (
  map (n: nameValuePair n nurAttrs.${n}) (
    builtins.filter (n: !isReserved n) (builtins.attrNames nurAttrs)
  )
)
