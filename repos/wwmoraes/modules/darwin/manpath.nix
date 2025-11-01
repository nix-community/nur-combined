{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.environment;
  makeDrvManPath = concatMapStringsSep ":" (p: if isDerivation p then "${p}/man" else p);
  readAbsPathsFromFile =
    path:
    let
      splitLines = splitString "\n";
      removeComments = filter (line: line != "" && !(hasPrefix "#" line));
      do = path: removeComments (splitLines (readFile path));
    in
    lists.optionals (pathExists path) (do path);
  readAbsPathsFromDir =
    path:
    let
      inherit (builtins) readDir;
      isRegular = _: type: type == "regular";
      prefixWith = prefix: path: prefix + "/" + path;
      prefixAllWith = prefix: map (prefixWith prefix);
      listRegularFiles = attrs: attrNames (attrsets.filterAttrs isRegular attrs);
      readDirRegularFiles = path: prefixAllWith path (listRegularFiles (readDir path));
      do = path: lists.flatten (map readAbsPathsFromFile (readDirRegularFiles path));
    in
    lists.optionals (pathExists path) (do path);
in
{
  meta.maintainers = [
    maintainers.wwmoraes or "wwmoraes"
  ];

  options = {
    environment.manPath = mkOption {
      type = types.listOf (types.either types.path types.str);
      default = [ ];
      example = [ "$HOME/.local/share/man" ];
      description = "The set of paths that are added to MANPATH.";
      apply = x: if isList x then makeDrvManPath x else x;
    };
  };
  config = {
    environment.manPath = mkMerge [
      (mkOrder 1200 (readAbsPathsFromFile "/etc/manpaths"))
      (mkOrder 1300 (readAbsPathsFromDir "/etc/manpaths.d"))
    ];

    environment.variables = {
      MANPATH = cfg.manPath;
    };
  };
}
