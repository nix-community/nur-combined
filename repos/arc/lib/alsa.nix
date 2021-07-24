{ lib }: with lib; let
  needsQuote = value: hasInfix " " value || hasInfix "'" value || hasInfix "$" value || hasInfix "," value  || hasInfix "/" value;
  quotedStr = name: ''"${name}"'';
  quotedKey = name:
    if needsQuote name
    then ''"${name}"''
    else name;
  alsaConf = conf: let
    directives =
      if isAttrs conf then alsaConfDirectives conf
      else if isList conf then concatMap alsaConfDirectives conf
      else throw "invalid alsaconf type";
  in concatStringsSep "\n" ([
    "Syntax 3"
  ] ++ directives);
  alsaConfDirectives = conf: mapAttrsToList alsaConfDirective conf;
  alsaConfDirective = key: value: let
    keyStr =
      if isString key
      then quotedKey key
      else concatMapStringsSep "." quotedKey key;
  in "${keyStr} " + alsaConfValue value;
  alsaListValue = value:
    if isString value then quotedStr value
    else if isAttrs value then concatStringsSep "\n" (alsaConfDirectives value)
    else toString value;
  alsaConfValue = value:
    if isString value then quotedStr value
    else if isList value then "[\n" + concatMapStringsSep "\n" alsaListValue value + "\n]"
    else if isAttrs value then "{\n" + concatStringsSep "\n" (alsaConfDirectives value) + "\n}"
    else toString value;
  alsaDirectiveTypePrimitives = with types; [
    str int float
  ];
  alsaDirectiveType = with types; oneOf ([
    (listOf (oneOf (alsaDirectiveTypePrimitives ++ singleton (attrsOf (oneOf alsaDirectiveTypePrimitives)))))
    (attrsOf alsaDirectiveType)
  ] ++ alsaDirectiveTypePrimitives);
in {
  inherit alsaConf alsaConfDirective alsaDirectiveType;
}
