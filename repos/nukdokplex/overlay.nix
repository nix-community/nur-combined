{ includeLib ? false }: prev: final:
let
  reservedAttrs = [ "lib" "modules" ];
  isReserved = attr: builtins.elem attr reservedAttrs;
  module = import ./default.nix { pkgs = final; };
in
(
  builtins.listToAttrs
    (
      builtins.map
        (attrName: { name = attrName; value = module.${attrName}; })
        (
          builtins.filter
            (n: !isReserved n)
            (builtins.attrNames module)
        )
    )
) // (
  if includeLib
  then {
    lib = prev.lib // { nukdokplex = module.lib; };
  }
  else { }
)
