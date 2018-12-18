{ lib, snakeToCamel, camelToSnake }:

with lib;
with builtins;

rec {
  transformAttrNames = transform: mapAttrs' (name: value: nameValuePair (transform name) value);

  # attrsSnakeToCamel { foo_bar = "whatever"; } => { fooBar = "whatever"; }
  attrsSnakeToCamel = transformAttrNames snakeToCamel;
  # attrsCamelToSnake = { fooBar = "whatever"; } => { foo_bar = "whatever"; }
  attrsCamelToSnake = transformAttrNames camelToSnake;
}
