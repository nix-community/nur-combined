{ lib }:
rec {
  drvPaths =
    attrs:
    builtins.concatMap (
      key:
      let
        val = attrs.${key};
      in
      if lib.isDerivation val then
        [ [ key ] ]
      else if builtins.isAttrs val then
        map (path: [ key ] ++ path) (drvPaths val)
      else
        [ ]
    ) (builtins.attrNames attrs);

  flattenTree =
    attrs:
    builtins.listToAttrs (
      map (
        path: lib.nameValuePair (builtins.concatStringsSep "/" path) (lib.attrByPath path null attrs)
      ) (drvPaths attrs)
    );
}
