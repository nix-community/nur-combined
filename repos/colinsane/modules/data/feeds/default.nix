{ lib, ... }:

let
  inherit (builtins) concatLists concatStringsSep foldl' fromJSON map readDir readFile;
  inherit (lib) hasSuffix listToAttrs mapAttrsToList removeSuffix splitString;

  # given a path to a .json file relative to sources, construct the best feed object we can.
  # the .json file could be empty, in which case we make assumptions about the feed based
  # on its fs path.
  # Type: feedFromSourcePath :: String -> { name = String; value = feed; }
  feedFromSourcePath = json-path:
    assert hasSuffix "/default.json" json-path;
    let
      canonical-name = removeSuffix "/default.json" json-path;
      default-url = "https://${canonical-name}";
      feed-details = { url = default-url; } // (tryImportJson (./sources/${json-path}));
    in { name = canonical-name; value = mkFeed feed-details; };

  # TODO: for now, feeds are just ordinary Attrs.
  # in the future, we'd like to set them up with an update script.
  mkFeed = { url, ... }@details: details;

  # return an AttrSet representing the json at the provided path,
  # or {} if the path is empty.
  tryImportJson = path:
    let
      as-str = readFile path;
    in
      if as-str == "" then
        {}
      else
        fromJSON as-str;

  sources = enumerateFilePaths ./sources;

  # like `lib.listFilesRecursive` but does not mangle paths.
  # Type: enumerateFilePaths :: path -> [String]
  enumerateFilePaths = base:
    concatLists (
      mapAttrsToList
        (name: type:
          if type == "directory" then
            # enumerate this directory and then prefix each result with the directory's name
            map (e: "${name}/${e}") (enumerateFilePaths (base + "/${name}"))
          else
            [ name ]
        )
        (readDir base)
    );
in
  listToAttrs (map feedFromSourcePath sources)
