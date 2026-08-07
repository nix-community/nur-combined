{
  pkgs ? import <nixpkgs> { },
  packages ? import ../. args,
  ...
}@args:

let
  inherit (pkgs) lib;
  inherit (lib)
    foldl'
    isAttrs
    isDerivation
    toList
    ;

  updatables =
    prefix: set:
    foldl' (
      acc: key:
      let
        value = set.${key} or null;
        path = if prefix == "" then key else "${prefix}.${key}";
      in
      if value == null || value == { } || builtins.isFunction value || value ? __functor then
        acc
      else if
        isDerivation value && value ? passthru && value.passthru ? updateScript && value ? version
      then
        acc
        ++ [
          {
            attrPath = path;
            name = value.name or path;
            pname = value.pname or key;
            inherit (value) version;
            updateScript = map toString (toList (value.updateScript.command or value.updateScript));
          }
        ]
      else if isAttrs value && (!isDerivation value) then
        acc ++ updatables path value
      else
        acc
    ) [ ] (builtins.attrNames set);

in
updatables "" (removeAttrs packages [ "_bartPackages" ])
