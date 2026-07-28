{ lib, ... }: rec {
  /**
    # Type

    ```
    mapAttrNames :: (${name_a} -> ${name_b}) -> { ${name_a} :: a; } -> { ${name_b} :: a; }
    ```
  */
  mapAttrNames =
    f: attrs:
    lib.mapAttrs' (name: value: {
      name = f name;
      inherit value;
    }) attrs;

  _tests.mapAttrNames.simple =
    assert
      (mapAttrNames (name: "prefix-${name}") {
        a = "a";
        b = "b";
      }) == {
        prefix-a = "a";
        prefix-b = "b";
      };
    true;
  _tests.mapAttrNames.overwrite =
    assert lib.elem
      (mapAttrNames (_: "a") {
        c = "c";
        d = "d";
      }).a
      [
        "c"
        "d"
      ];
    true;

  # based off of https://github.com/NixOS/nixpkgs/blob/d792a6e0cd4ba35c90ea787b717d72410f56dc40/lib/attrsets.nix#L1577
  /**
    Merge a list of attribute sets together using the `//` operator.
    In case of duplicate attributes, values from later list elements take precedence over earlier ones.
    The result is the same as `foldl mergeAttrs { }`, but the performance is better for large inputs.
    For n list elements, each with an attribute set containing m unique attributes, the complexity of this operation is O(nm log n).

    # Type

    ```
    mapMergeAttrs :: (a -> a -> a) -> [ { ${name} :: a } ] -> { ${name} :: a }
    ```

    # Examples
    :::{.example}
    ## `vaculib.mapMergeAttrs` usage example

    ```nix
    mapMergeAttrs (l: r: l + r) [ { a = 1; b = 2; } { b = 4; c = 8; } ]
    => { a = 1; b = 6; c = 8; }
    ```

    :::
  */
  mapMergeAttrs =
    mergeValues: list:
    let
      merge =
        a: b:
        let
          naiveMerge = a // b;
        in
        builtins.mapAttrs (
          name: val: if a ? ${name} && b ? ${name} then mergeValues a.${name} b.${name} else val
        ) naiveMerge;
      # `binaryMerge start end` merges the elements at indices `index` of `list` such that `start <= index < end`
      # Type: Int -> Int -> Attrs
      binaryMerge =
        start: end:
        # assert start < end; # Invariant
        if end - start >= 2 then
          # If there's at least 2 elements, split the range in two, recurse on each part and merge the result
          # The invariant is satisfied because each half will have at least 1 element
          let
            left = binaryMerge start (start + (end - start) / 2);
            right = binaryMerge (start + (end - start) / 2) end;
          in
          merge left right
        else
          # Otherwise there will be exactly 1 element due to the invariant, in which case we just return it directly
          builtins.elemAt list start;
    in
    if list == [ ] then
      # Calling binaryMerge as below would not satisfy its invariant
      { }
    else
      binaryMerge 0 (builtins.length list);

  _tests.mapMergeAttrs.simple =
    assert
      (mapMergeAttrs (l: r: l + r) [
        {
          a = 1;
          b = 2;
        }
        {
          b = 4;
          c = 8;
        }
      ]) == {
        a = 1;
        b = 6;
        c = 8;
      };
    true;

  # like the nixpkgs-lib unionOfDisjoint, but errors immediately if there are any conflicts
  unionOfDisjoint =
    a1: a2:
    let
      i = builtins.intersectAttrs a1 a2;
      conflictsStr = lib.pipe i [
        builtins.attrNames
        (map lib.strings.escapeNixIdentifier)
        (lib.concatStringsSep ", ")
      ];
    in
    lib.throwIf (i != { }) "vaculib.unionOfDisjoint: conflicting attrs: ${conflictsStr}" (a1 // a2);

  _tests.unionOfDisjoint.simple =
    assert
      (unionOfDisjoint { a = 1; } { b = 2; }) == {
        a = 1;
        b = 2;
      };
    true;
  _tests.unionOfDisjoint.errorOnConflict =
    assert !(builtins.tryEval (unionOfDisjoint { a = 1; } { a = 1; })).success;
    true;
}
