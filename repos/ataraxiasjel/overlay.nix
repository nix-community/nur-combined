# _final: prev:
# let
#   isReserved = n: n == "lib" || n == "overlays" || n == "modules";
#   nameValuePair = n: v: {
#     name = n;
#     value = v;
#   };
#   nurAttrs = import ./pkgs/default.nix { pkgs = prev; };

# in
# builtins.listToAttrs (
#   map (n: nameValuePair n nurAttrs.${n}) (
#     builtins.filter (n: !isReserved n) (builtins.attrNames nurAttrs)
#   )
# )
_final: prev:
let
  ci = import ./ci.nix { pkgs = prev; };
in
ci.notReserved
