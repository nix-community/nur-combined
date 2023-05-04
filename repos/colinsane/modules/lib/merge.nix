{ lib, sane-lib, ... }:

rec {
  # type-checked `lib.mkMerge`, intended to be usable at the top of a file.
  # `take` is a function which defines a spec enforced against every item to be merged.
  # for example:
  #   take = f: { x = f.x; y.z = f.y.z; };
  # - the output is guaranteed to have an `x` attribute and a `y.z` attribute and nothing else.
  # - each output is a `lib.mkMerge` of the corresponding paths across the input lists.
  # - if an item in the input list defines an attr not captured by `f`, this function will throw.
  #
  # Type: mkTypedMerge :: (Attrs -> Attrs) -> [Attrs] -> Attrs
  mkTypedMerge = take: l:
    let
      pathsToMerge = findTerminalPaths take [];
      discharged = dischargeAll l pathsToMerge;
      merged = builtins.map (p: lib.setAttrByPath p (mergeAtPath p discharged)) pathsToMerge;
    in
      assert builtins.all (assertNoExtraPaths pathsToMerge) discharged;
      sane-lib.joinAttrsetsRecursive merged;

  # `take` is as in mkTypedMerge. this function queries which items `take` is interested in.
  # for example:
  #   take = f: { x = f.x; y.z = f.y.z; };
  # - for `path == []` we return the toplevel attr names: [ "x" "y"]
  # - for `path == [ "y" ]` we return [ "z" ]
  # - for `path == [ "x" ]` or `path == [ "y" "z" ]` we return []
  #
  # Type: findSubNames :: (Attrs -> Attrs) -> [String] -> [String]
  findSubNames = take: path:
    let
      # define the current path, but nothing more.
      curLevel = lib.setAttrByPath path {};
      # `take curLevel` will act one of two ways here:
      # - { $path = f.$path; }  => { $path = {}; };
      # - { $path.subAttr = f.$path.subAttr; }  => { $path = { subAttr = ?; }; }
      # so, index $path into the output of `take`,
      # and if it has any attrs (like `subAttr`) that means we're interested in those too.
      nextLevel = lib.getAttrFromPath path (take curLevel);
    in
      builtins.attrNames nextLevel;

  # computes a list of all terminal paths that `take` is interested in,
  # where each path is a list of attr names to descend to reach that terminal.
  # Type: findTerminalPaths :: (Attrs -> Attrs) -> [String] -> [[String]]
  findTerminalPaths = take: path:
    let
      subNames = findSubNames take path;
    in if subNames == [] then
      [ path ]
    else
      lib.concatMap (name: findTerminalPaths take (path ++ [name])) subNames;

  # ensures that all nodes in the attrset from the root to and including the given path
  # are ordinary attrs -- if they exist.
  # this has to return a list of Attrs, in case any portion of the path was previously merged.
  # by extension, each returned item is a subset of the original item, and might not have *all* the paths that the original has.
  # Type: dischargeToPath :: [String] -> Attrs -> [Attrs]
  dischargeToPath = path: i:
    let
      items = lib.pushDownProperties i;
      # now items is a list where every element is undecorated at the toplevel.
      # e.g. each item is an ordinary attrset or primitive.
      # we still need to discharge the *rest* of the path though, for every item.
      name = lib.head path;
      downstream = lib.tail path;
      dischargeDownstream = it: if path != [] && it ? name then
        builtins.map (v: it // { "${name}" = v; }) (dischargeToPath downstream it."${name}")
      else
        [ it ];
    in
      lib.concatMap dischargeDownstream items;

  # discharge many items but only over one path.
  # Type: dischargeItemsToPaths :: [Attrs] -> String -> [Attrs]
  dischargeItemsToPath = l: path: builtins.concatMap (dischargeToPath path) l;

  # Type: dischargeAll :: [Attrs] -> [String] -> [Attrs]
  dischargeAll = l: paths:
    builtins.foldl' dischargeItemsToPath l paths;

  # merges all present values for the provided path
  # Type: mergeAtPath :: [String] -> [Attrs] -> (lib.mkMerge)
  mergeAtPath = path: l:
    let
      itemsToMerge = builtins.filter (lib.hasAttrByPath path) l;
    in lib.mkMerge (builtins.map (lib.getAttrFromPath path) itemsToMerge);

  # check that attrset `i` contains no terminals other than those specified in (or direct ancestors of) paths
  assertNoExtraPaths = paths: i:
    let
      # since the act of discharging should have forced all the relevant data out to the leaves,
      # we just set each expected terminal to null (initializing the parents when necessary)
      # and that gives a standard value for any fully-consumed items that we can do equality comparisons with.
      wipePath = acc: path: lib.recursiveUpdate acc (lib.setAttrByPath path null);
      remainder = builtins.foldl' wipePath i paths;
      expected-remainder = builtins.foldl' wipePath {} paths;
    in
      assert remainder == expected-remainder; true;
}
