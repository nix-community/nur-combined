{ pkgs }:
with pkgs.lib; with builtins; rec {
  toJavaPropertiesStr = let
    strVal = val: if isBool val
      then if val then "true" else "false"
      else toString val;
    go = ctx: val: if isAttrs val
      then concatStringsSep "\n" (map (key: go (ctx ++ [key]) val.${key}) (attrNames val))
      else "${concatStringsSep "." ctx} = ${strVal val}";
  in go [];
}
