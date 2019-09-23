self: with self; let
  toTomlSection = k: attrs: ''
    [${toTomlKey k}]
    ${toTomlAttrs attrs}
  '';
  toTomlList = k: attrs: concatMapStringsSep "\n\n" (attrs: ''
    [[${toTomlKey k}]]
    ${toTomlAttrs attrs}
  '') attrs;
  toTomlAttrs = attrs: concatStringsSep "\n" (mapAttrsToList toTomlKeyValue attrs);
  toTomlKey = k: if builtins.match "[A-Za-z0-9_-]+" k != null
    then k
    else ''"${k}"'';
  toTomlKeyValue = k: v: "${toTomlKey k} = ${toTomlValue v}";
  toTomlString = s: # TODO: https://github.com/toml-lang/toml#string escapes
    ''"${replaceStrings [''"'' ''\''] [''\"'' ''\\''] s}"'';
  toTomlValue = v:
    if isInt v || isFloat v then "${toString v}"
    else if v == true then "true"
    else if v == false then "false"
    else if isList v then ''[${concatMapStringsSep ", " toTomlValue v}]''
    else if isAttrs v then ''{ ${concatStringsSep ", " (mapAttrsToList toTomlKeyValue v)} }''
    else toTomlString (toString v);
in {
  toTOML = attrs: let
    categorized = mapAttrs (_: v:
      if isAttrs v then "attrs"
      else if isList v && all (v: isAttrs v) v then "list"
      else "value"
    ) attrs;
    cat = cat: filterAttrs (_: v: v != null) (mapAttrs (k: v: if v == cat then attrs.${k} else null) categorized);
  in concatStringsSep "\n\n" (filter (v: v != "") [
    (toTomlAttrs (cat "value"))
    (concatStringsSep "\n\n" (mapAttrsToList toTomlSection (cat "attrs")))
    (concatStringsSep "\n\n" (mapAttrsToList toTomlList (cat "list")))
  ]);
}
