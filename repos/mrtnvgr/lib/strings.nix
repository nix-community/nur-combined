{ pkgs }: {
  quote = x: if pkgs.lib.hasInfix x "\"" then
    "'${x}'"
  else
    "\"${x}\"";
}
