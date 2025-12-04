{ pkgs }: {
  quote = x: if pkgs.lib.hasInfix "\"" x then
    "'${x}'"
  else
    "\"${x}\"";

  unalias = table: x: if builtins.hasAttr x table then table.${x} else x;
}
