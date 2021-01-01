{ lib, aasgLib }:
let
  inherit (builtins) attrNames concatLists concatMap concatStringsSep foldl' intersectAttrs isAttrs listToAttrs;
  inherit (lib) isDerivation mapAttrsToList;
in
rec {
  /*
   * Return a copy of the input attribute set with its (non-recursive)
   * attribute names capitalized.  Useful when mapping between Nixpkgs
   * and systemd.
   */
  capitalizeAttrNames = /*attrs:*/
    lib.mapAttrs' (name: value: lib.nameValuePair (aasgLib.capitalize name) value);

  /* concatMapAttrs :: set -> (string -> any -> set) -> set
   *
   * What `concatMap` is to `map`, this is to `mapAttrs`.  Namely, call
   * a function that produces a set for each attribute in the passed set
   * and merge the resulting sets using the update operator //.
   */
  concatMapAttrs = mapper: attrs:
    foldl' (prev: name: prev // (mapper name attrs.${name})) { } (builtins.attrNames attrs);

  /* concatMapAttrs' :: set -> (string -> any -> [NameValuePair]) -> set
   *
   * What `concatMap` is to `map`, this is to `mapAttrs'`.  Namely, call
   * a function to produce multiple attributes for each attribute in the
   * passed set.
   *
   * This function differs from `concatMapAttrs'` by expecting a list of
   * name-value pairs as result of the mapping function, instead of a
   * set.
   */
  concatMapAttrs' = mapper: attrs:
    listToAttrs (concatMap (name: mapper name attrs.${name}) (attrNames attrs));

  /* concatMapAttrsToList :: (string -> any -> [any]) -> set -> [any]
   *
   * Like mapAttrsToList, but allows multiple values to be returned
   * from the mapping function as a list.
   */
  concatMapAttrsToList = mapper: attrs: concatLists (mapAttrsToList mapper attrs);

  /* copyAttrsByPath :: [string] -> set -> set
   *
   * Recreate attrs recursively with only the attributes listed in
   * paths.
   */
  copyAttrsByPath = paths: attrs:
    builtins.foldl' updateNewRecursive { }
      (map (path: lib.setAttrByPath path (lib.getAttrFromPath path attrs)) paths);

  /* recurseIntoAttrs :: set -> set
   *
   * Polyfill of nixpkgs.recurseIntoAttrs for when it's not available
   * under lib.
   */
  recurseIntoAttrs = lib.recurseIntoAttrs or (attrs: attrs // { recurseForDerivations = true; });

  /* recurseIntoAttrsRecursive :: set -> set
   *
   * Recursive variant of recurseIntoAttrs, mark attrs as containing
   * derivations recursively until a derivation or non-attrset value
   * is reached.
   */
  recurseIntoAttrsRecursive = attrs:
    if isAttrs attrs && ! isDerivation attrs
    then recurseIntoAttrs (lib.mapAttrs (_: recurseIntoAttrsRecursive) attrs)
    else attrs;

  /*
   * Like the update operator `//`, but throws if the right-hand
   * attrset contains an attribute that already exists in the
   * left-hand side.
   *
   * See `lib.attrsets.overrideExisting` for the opposite behavior.
   */
  updateNew = into: new:
    let
      commonAttributes = attrNames (intersectAttrs into new);
    in
    if commonAttributes == [ ]
    then into // new
    else throw "attrsets have the following attributes in common: ${concatStringsSep ", " commonAttributes}";

  /*
   * Recursive variant of updateNew.
   */
  updateNewRecursive = into: new:
    let
      commonAttributes = attrNames (intersectAttrs into new);
      commonNonAttrsets = builtins.filter (name: ! (isAttrs into.${name} && isAttrs new.${name})) commonAttributes;
      mergedCommonAttrsets = builtins.listToAttrs
        (map (name: lib.nameValuePair name (updateNewRecursive into.${name} new.${name})) commonAttributes);
    in
    if commonNonAttrsets == [ ]
    then into // new // mergedCommonAttrsets
    else
      throw "attrsets have the following attributes in common: ${concatStringsSep ", " commonNonAttrsets}";
}
