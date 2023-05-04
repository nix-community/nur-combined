{ lib, ... }:

let
sane-lib = rec {
  feeds = import ./feeds.nix { inherit lib; };
  fs = import ./fs.nix { inherit lib; };
  merge = import ./merge.nix { inherit lib sane-lib; };
  path = import ./path.nix { inherit lib; };
  types = import ./types.nix { inherit lib; };

  # re-exports
  inherit (merge) mkTypedMerge;

  # like `builtins.listToAttrs` but any duplicated `name` throws error on access.
  # Type: listToDisjointAttrs :: [{ name :: String, value :: Any }] -> AttrSet
  listToDisjointAttrs = l: joinAttrsets (builtins.map nameValueToAttrs l);

  # true if p is a prefix of l (even if p == l)
  # Type: isPrefixOfList :: [Any] -> [Any] -> bool
  isPrefixOfList = p: l: (lib.sublist 0 (lib.length p) l) == p;

  # merges N attrsets
  # Type: joinAttrsets :: [AttrSet] -> AttrSet
  joinAttrsets = l: lib.foldl' lib.attrsets.unionOfDisjoint {} l;

  # merges N attrsets, recursively
  # Type: joinAttrsetsRecursive :: [AttrSet] -> AttrSet
  joinAttrsetsRecursive = l: lib.foldl' (lib.attrsets.recursiveUpdateUntil (path: lhs: rhs: false)) {} l;

  # evaluate a `{ name, value }` pair in the same way that `listToAttrs` does.
  # Type: nameValueToAttrs :: { name :: String, value :: Any } -> Any
  nameValueToAttrs = { name, value }: {
    "${name}" = value;
  };

  # if `maybe-null` is non-null, yield that. else, return the `default`.
  withDefault = default: maybe-null: if maybe-null != null then
    maybe-null
  else
    default;

  # removes null entries from the provided AttrSet. acts recursively.
  # Type: filterNonNull :: AttrSet -> AttrSet
  filterNonNull = attrs: lib.filterAttrsRecursive (n: v: v != null) attrs;

  # return only the subset of `attrs` whose name is in the provided set.
  # Type: filterByName :: [String] -> AttrSet
  filterByName = names: attrs: lib.filterAttrs
    (name: value: builtins.elem name names)
    attrs;

  # transform a list into an AttrSet via a function which maps an element to a { name, value } pair.
  # it's an error for the same name to be specified more than once
  # Type: mapToAttrs :: (a -> { name :: String, value :: Any }) -> [a] -> AttrSet
  mapToAttrs = f: list: listToDisjointAttrs (builtins.map f list);

  # flatten a nested AttrSet into a list of { path = [String]; value } items.
  # the output contains only non-attr leafs.
  # so e.g. { a.b = 1; }  ->  [ { path = ["a" "b"]; value = 1; } ]
  # but e.g. { a.b = {}; } -> []
  #
  # Type: flattenAttrs :: AttrSet[AttrSet|Any] -> [{ path :: String, value :: Any }]
  flattenAttrs = flattenAttrs' [];
  flattenAttrs' = path: value: if builtins.isAttrs value then (
    builtins.concatLists (
      lib.mapAttrsToList
        (name: flattenAttrs' (path ++ [ name ]))
        value
    )
  ) else [
    {
      inherit path value;
    }
  ];
};
in sane-lib
