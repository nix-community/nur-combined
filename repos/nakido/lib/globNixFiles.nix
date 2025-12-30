lib: path:
let
  inherit (lib)
    attrNames
    filterAttrs
    concatMap
    lists
    ;
  globNixFiles =
    dirPath:
    let
      contents = builtins.readDir dirPath;
      files = filterAttrs (
        name: type:
        type == "regular"
        && lib.strings.hasSuffix ".nix" name
        && !(dirPath == path && name == "default.nix")
      ) contents;
      dirs = filterAttrs (name: type: type == "directory") contents;
    in
    (map (name: dirPath + "/${name}") (attrNames files))
    ++ (concatMap (name: globNixFiles (dirPath + "/${name}")) (attrNames dirs));
in
globNixFiles path