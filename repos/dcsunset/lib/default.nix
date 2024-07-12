{ lib }:

(import ./network.nix { inherit lib; }) //
(
  with lib;
  rec {
    # fitler file names with predicate in dir
    filterDir = pred: dir:
      builtins.attrNames (
        filterAttrs
          pred
          (builtins.readDir dir)
      );

    # read all modules in a directory as a list
    # dir should be a path
    readModules = dir: map
      (m: dir + "/${m}")
      (filterDir
        # if it's a directory, it should contain default.nix
        (n: v: v == "directory" || strings.hasSuffix ".nix" n)
        dir);

    # list names of all subdirectories in a dir
    listSubdirNames = filterDir (n: v: v == "directory");

    # list paths of all subdirectories in a dir
    listSubdirPaths = dir: map (x: dir + "/${x}") (listSubdirNames dir);

    # import all modules in subdirs
    importSubdirs = dir: map import (listSubdirPaths dir);

    # read multiple files and concat them into one string by newlines
    readFiles = files: concatStringsSep "\n" (
      map builtins.readFile files
    );

    recursiveMergeAttrs = attrs: foldl' (acc: attr: recursiveUpdate acc attr) {} attrs;

    # Remove multiple possible suffixes
    removeSuffixes = suffixes: str:
      foldl'
        (acc: suffix: removeSuffix suffix acc)
        str
        suffixes;
  }
)
