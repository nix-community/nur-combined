{nixpkgs, ...}: let
  inherit (builtins) attrNames concatMap isAttrs listToAttrs;
  inherit (nixpkgs.lib.attrsets) nameValuePair;
in {
  attrsets = {
    # Convert a nested attribute set into a flat one.
    #
    # Parameters:
    #
    #  - `valueCond`: the predicate which determines whether the value should
    #    be included into the resulting flat set.  Takes two arguments: `path`
    #    (a list of strings describing the path from the root of `nestedAttrs`
    #    to the value) and `value` (the value at `path` in `nestedAttrs`).
    #
    #    If `valueCond` returns true, `recurseCond` is not called, and `value`
    #    is returned as part of the resulting flat set and not recursed into
    #    even if it is an attribute set.
    #
    #  - `recurseCond`: the predicate which determines whether the value (which
    #    is already verified to be an attribute set) should be recursed into.
    #    Takes two arguments: `path` (a list of strings describing the path
    #    from the root of `nestedAttrs` to the value) and `value` (the value at
    #    `path` in `nestedAttrs`).
    #
    #    If both `recurseCond` and `valueCond` return false, the value will be
    #    ignored (neither recursed into nor added to the resulting flat set).
    #
    #  - `pathToName`: the function which takes the attribute path from the
    #    root of `nestedAttrs` and returns the name for the corresponding item
    #    in the resulting flat set.
    #
    #  - `nestedAttrs`: The attribute set to convert.
    #
    # Note that `valueCond`, `recurseCond` and `pathToName` can potentially be
    # called for the `nestedAttrs` value itself with an empty list as the path.
    #
    flattenAttrs = valueCond: recurseCond: pathToName: nestedAttrs: let
      recurse = path: value:
        if valueCond path value
        then [(nameValuePair (pathToName path) value)]
        else if (isAttrs value) && (recurseCond path value)
        then concatMap (n: recurse (path ++ [n]) value.${n}) (attrNames value)
        else [];
    in
      listToAttrs (recurse [] nestedAttrs);
  };
}
