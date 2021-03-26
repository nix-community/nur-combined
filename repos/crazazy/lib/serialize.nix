let
  inherit (builtins) attrNames isAttrs isBool isList isString concatStringsSep toString;
  serialize = x: if isAttrs x then "{ ${concatStringsSep " " (map (k: "${k} = ${serialize x.${k}};") (attrNames x))}}" else
  if isList x then "[ ${concatStringsSep " " (map (e: "(${serialize e})") x)} ]" else
  if isString x then "\"${x}\"" else
  if isBool x then (if x then "true" else "false") else
  toString x;
in
  serialize
