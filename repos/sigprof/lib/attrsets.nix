{nixpkgs, ...}: let
  inherit (builtins) attrNames concatMap isAttrs listToAttrs;
  inherit (nixpkgs.lib.attrsets) nameValuePair;

  # concatMapAttrsToListRecursive ::
  #   ([string] -> any -> [any]|null) -> set|any -> [any]
  #
  # Process attribute values of a set recursively in the depth-first order,
  # then concatenate the results of processing into a flat list.
  #
  # Equivalent to `concatMapAttrsToListRecursive' mapper [] rootValue`.
  #
  # Arguments:
  #
  # - `mapper`: The processing function.  Takes two arguments: `path` (a list
  #   of strings describing the path to the current value) and `value` (the
  #   current value).
  #
  #   The return value of `mapper` must be one of the following:
  #   - A list; in this case the returned list will be concatenated into the
  #     result of `concatMapAttrsToListRecursive`, and the current value will
  #     not be processed recursively even if it is a set.  Returning an empty
  #     list is allowed and will result in effectively ignoring the value.
  #   - `null`; in this case `concatMapAttrsToListRecursive` will process the
  #     current value recursively if it is a set, or ignore it otherwise.
  #
  #   Note that `mapper` will first be called for the `rootValue` itself, and
  #   must handle that situation correctly (by returning `null` if recursive
  #   processing is desired).
  #
  # - `rootValue`: The set to be processed (although a value of any type
  #   acceptable for `mapper` could be passed, in which case the function will
  #   return an empty list if `mapper` returns `null`).
  #
  concatMapAttrsToListRecursive = mapper: rootValue:
    concatMapAttrsToListRecursive' mapper [] rootValue;

  # concatMapAttrsToListRecursive' ::
  #   ([string] -> any -> [any]|null) -> [string] -> set|any -> [any]
  #
  # Process attribute values of a set recursively in the depth-first order,
  # then concatenate the results of processing into a flat list.
  #
  # The difference from `concatMapAttrsToListRecursive` is that this function
  # has an additional argument to specify the root path instead of starting
  # from an empty list, so it can be used to process a subtree without wrapping
  # the processing function to adjust the path.
  #
  # Arguments:
  #
  # - `mapper`: The processing function.  Takes two arguments: `path` (a list
  #   of strings describing the path to the current value) and `value` (the
  #   current value).
  #
  #   The return value of `mapper` must be one of the following:
  #   - A list; in this case the returned list will be concatenated into the
  #     result of `concatMapAttrsToListRecursive'`, and the current value will
  #     not be processed recursively even if it is a set.  Returning an empty
  #     list is allowed and will result in effectively ignoring the value.
  #   - `null`; in this case `concatMapAttrsToListRecursive'` will process the
  #     current value recursively if it is a set, or ignore it otherwise.
  #
  #   Note that `mapper` will first be called for the `rootValue` itself, and
  #   must handle that situation correctly (by returning `null` if recursive
  #   processing is desired).
  #
  # - `rootPath`: A list of strings which will be used as the path for
  #   `rootValue`.
  #
  # - `rootValue`: The attribute set to be processed (although a value of any
  #   type acceptable for `mapper` could be passed, in which case the function
  #   will return an empty list if `mapper` returns `null`).
  #
  concatMapAttrsToListRecursive' = mapper: rootPath: rootValue: let
    result = mapper rootPath rootValue;
  in
    if result != null
    then result
    else if isAttrs rootValue
    then concatMap (n: concatMapAttrsToListRecursive' mapper (rootPath ++ [n]) rootValue.${n}) (attrNames rootValue)
    else [];

  # flattenAttrs ::
  #   ([string] -> any -> bool) -> ([string] -> any -> bool) -> ([string] -> string) -> set|any -> set
  #
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
    process = path: value:
      if valueCond path value
      then [(nameValuePair (pathToName path) value)]
      else if (isAttrs value) && (recurseCond path value)
      then null
      else [];
  in
    listToAttrs (concatMapAttrsToListRecursive process nestedAttrs);
in {
  attrsets = {
    inherit concatMapAttrsToListRecursive concatMapAttrsToListRecursive' flattenAttrs;
  };
}
