{ lib }: with lib; let
  luaTableKey = k: let
    needsEscape = builtins.match "[a-zA-Z_]+[a-zA-Z0-9_]*" k == null;
    escaped = escapedKey k;
  in if escaped != null then "[${escaped}]"
    else if needsEscape then "[${serializeString k}]"
    else k;
  escapedKey = k: if hasPrefix "__lua" k then removePrefix "__lua" k else null;
  escapeKey = k: "__lua${serializeExpr k}";
  serializeList = list: "{" + concatMapStringsSep ", " serializeExpr list + "}";
  serializeTable = attrs: "{" + concatStringsSep ", " (mapAttrsToList (k: v: "${luaTableKey k}=${serializeExpr v}") attrs) + "}";
  serializeString = str: ''"'' + replaceStrings [ ''"'' "\\" "\n" ] [ ''\"'' ''\\'' ''\n'' ] str + ''"'';
  serializeExpr = value:
    if isString value then serializeString value
    else if isList value then serializeList value
    else if isAttrs value then serializeTable value
    else if value == true then "true"
    else if value == false then "false"
    else if value == null then "nil"
    else toString value;
  toTable = value: listToAttrs (imap1 (i: v: nameValuePair (escapeKey i) v) value);
in {
  inherit serializeExpr escapeKey toTable;
}
