_self: super:
let
  isReserved = n: n == "lib" || n == "overlays" || n == "modules";
  nameValuePair = n: v: { name = n; value = v; };
  nurAttrs = import ./default.nix { pkgs = super; };
  overlay =
    builtins.listToAttrs
      (map (n: nameValuePair n nurAttrs.${n})
        (builtins.filter (n: !isReserved n)
          (builtins.attrNames nurAttrs)));
in
overlay //
{
  # Reference: https://github.com/xeals/nur-packages/blob/master/overlay.nix
}
