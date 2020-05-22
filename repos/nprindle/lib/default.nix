{ pkgs }:

with builtins;
with pkgs.lib;

rec {
  # Map key-value pairs of an attribute set
  #   :: ({ name: k, value: v } -> { name: k', value: v' }) -> AttrSet k v -> AttrSet k' v'
  mapAttrPairs = f: attr:
    listToAttrs
    (map (n: f { name = n; value = getAttr n attr; })
    (attrNames attr));

  # Return paths to all the contents of a directory whose name and type match a
  # certain predicate
  #   :: (FileName -> FileType -> Bool) -> FilePath -> [FilePath]
  getDirContentsWith = pred: dir:
    map (x: dir + "/${x}")
    (attrNames
    (filterAttrs pred
    (readDir dir)));

  # Get all subdirectories in a directory
  #   :: FilePath -> [FilePath]
  getDirs = getDirContentsWith (_: type: type == "directory");

  # Get all files in a directory matching a predicate
  #   :: (FileName -> FileType -> Bool) -> FilePath -> [FilePath]
  getFilesWith = pred:
    let matches = name: type:
      pred name type && (type == "regular" || type == "symlink");
    in getDirContentsWith matches;

  # Get all files in a directory
  #   :: FilePath -> [FilePath]
  getFiles = getFilesWith (_: _: true);
}

