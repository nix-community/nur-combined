{ lib }:

let
  inherit (builtins) map readDir toString;
  inherit (lib) compose cons flip foldl' foldr id is;

  # defined here
  inherit (lib.filesystem) dlistNixDirTree dirPaths fileName isDir isHidden isNixFile isRegular;
  splitPath = lib.splitString "/";
in {
  fileName = path: lib.last (splitPath (toString path));
  dirName = path: lib.concatStringsSep "/" (lib.init (splitPath path));

  # file types returned by builtins.readDir
  isRegular = is "regular";
  isDir = is "directory";
  isSymlink = is "symlink";

  isHidden = path: lib.hasPrefix "." (fileName path);

  # type has the format returned by builtins.readDir
  isNixFile = path: type: isRegular type && lib.hasSuffix ".nix" path;

  # convert readDir output to a list of { path, type } pairs
  dirPaths = root: files: map (name:
    { path = root + "/${name}"; type = builtins.getAttr name files; }) (builtins.attrNames files);

  # list a directory (Type: Path -> [{ path, type }])
  listDir = path: dirPaths path (readDir path);

  fileType = path:
    let
      spath = toString path;
      files = readDir (path + "/..");
      name = fileName spath;
    in files.${name};

  # list a path recursively and flatten output,
  # but do not follow symlinks
  # base function with difference list
  # this function is not inherited in 'lib'
  dlistNixDirTree = { path, type }:
    if isHidden path
      then id
    else
    if isNixFile path type
      then cons path
    else
    if isDir type
      then let files = readDir path; in
      if isRegular (files."default.nix" or null)
        then cons path
      else
        foldl' (f: file: compose f (dlistNixDirTree file)) id (dirPaths path files)
    else id;

  listNixDirTrees = foldr dlistNixDirTree [];

  # does not recurse into dirs with default.nix
  listNixDirTree = path: dlistNixDirTree { inherit path; type = lib.fileType path; } [];

  # listNixDirTree which always lists the path given, even if it has a default.nix
  listNixDirTree' = compose lib.listNixDirs lib.listDir;
}
