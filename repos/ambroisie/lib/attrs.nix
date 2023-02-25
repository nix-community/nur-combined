{ lib, ... }:
let
  inherit (lib)
    filterAttrs
    foldl
    listToAttrs
    mapAttrs'
    nameValuePair
    recursiveUpdate
    ;
in
{
  # Filter a generated set of attrs using a predicate function.
  #
  # mapFilterAttrs ::
  #   (name -> value -> bool)
  #   (name -> value -> { name = any; value = any; })
  #   attrs
  mapFilterAttrs = pred: f: attrs: filterAttrs pred (mapAttrs' f attrs);

  # Generate an attribute set by mapping a function over a list of values.
  #
  # genAttrs' ::
  #   [ values ]
  #   (value -> { name = any; value = any; })
  #   attrs
  genAttrs' = values: f: listToAttrs (map f values);

  # Merge a list of attrs non-recursively, later values override previous ones.
  #
  # merge ::
  #   [ attrs ]
  #   attrs
  merge = foldl (a: b: a // b) { };

  # Merge a list of attrs recursively, later values override previous ones.
  #
  # recursiveMerge ::
  #   [ attrs ]
  #   attrs
  recursiveMerge = foldl recursiveUpdate { };

  # Rename each of the attributes in an attribute set using the mapping function
  #
  # renameAttrs ::
  #   (name -> new name)
  #   attrs
  renameAttrs = f: mapAttrs' (name: value: nameValuePair (f name) value);

  # Rename each of the attributes in an attribute set using a function which
  # takes the attribute's name and value as inputs.
  #
  # renameAttrs' ::
  #   (name -> value -> new name)
  #   attrs
  renameAttrs' = f: mapAttrs' (name: value: nameValuePair (f name value) value);
}
