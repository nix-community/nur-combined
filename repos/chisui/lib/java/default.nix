{ pkgs }:
with pkgs.lib;
with builtins;
rec {

  toJavaPropertiesStr =
    let strVal = val: if isBool val
          then if val then "true" else "false"
          else toString val;
        go = ctx: val: if isAttrs val
          then concatStringsSep "\n" (map (key: go (ctx ++ [key]) val.${key}) (attrNames val))
          else "${concatStringsSep "." ctx} = ${strVal val}";
    in go [];
  
  fromJavaProperties =
    let testRegex = reg: str: match reg str != null; 
        isEntry = l: isString l && testRegex "^[[:alnum:]].*" l;
        toValue = str:
          if testRegex "(true|false|null|([[:digit:]]+(\.[[:digit:]]+)?))" str then fromJSON str 
          else str;
        parseLine = l:
          let kv = split "[[:space:]]*=[[:space:]]*" l;
              key = splitString "." (head kv);
              val = toValue (lists.last kv);
          in lists.foldr (k: v: { ${k} = v; }) val key;
    in str: foldl' recursiveUpdate {} (map parseLine (filter isEntry (splitString "\n" str)));
}
