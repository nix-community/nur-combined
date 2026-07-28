{ lib, ... }: rec {
  /**
    # Type

    ```
    mapListToAttrs :: (a -> { name :: String; value :: b; }) -> [a] -> { ${name} :: b; }
    ```
  */
  mapListToAttrs = f: list: lib.listToAttrs (map f list);

  /**
    # Type

    ```
    mapNamesToAttrs :: (${name} -> a) -> [${name}] -> { ${name} :: a; }
    ```
  */
  mapNamesToAttrs = f: list: lib.genAttrs list f;

  /**
    # Type

    ```
    mapNamesToAttrsConst :: a -> [${name}] -> { ${name} :: a; }
    ```
  */
  mapNamesToAttrsConst = val: list: lib.genAttrs list (_: val);

  /**
    # Type
    ```
    isListWhere :: (a -> Bool) -> [a] -> Bool
    isListWhere :: (a -> Bool) -> b -> Bool
    ```
  */
  isListWhere = f: list: lib.isList list && lib.all f list;

  /**
    # Type
    ```
    reduce :: (a -> a -> a) -> b -> [ ] -> b
    reduce :: (a -> a -> a) -> b -> [a] -> a
    ```
  */
  reduce =
    f: onEmpty: list:
    let
      # from https://github.com/NixOS/nixpkgs/blob/78f6d5afc454ed4a558f6a483679be79ef22d08a/lib/attrsets.nix#L1608
      doMerge =
        start: end:
        let
          len = (end - start);
          mid = start + len / 2;
        in
        if len >= 2 then f (doMerge start mid) (doMerge mid end) else builtins.elemAt list start;
    in
    if list == [ ] then
      onEmpty
    else if (builtins.length list) == 1 then
      builtins.head list
    else
      doMerge 0 (builtins.length list);

  listMax = default: list: reduce (a: b: if a > b then a else b) default list;

  listMaxNonEmpty = list: listMax (throw "in vaculib.listMaxNonEmpty: list was empty") list;

  listMin = default: list: reduce (a: b: if a < b then a else b) default list;

  listMinNonEmpty = list: listMax (throw "in vaculib.listMinNonEmpty: list was empty") list;

  /**
    # Type
    ```
    mapReduce :: (x -> a) -> (a -> a -> a) -> b -> [ ] -> b
    mapReduce :: (x -> a) -> (a -> a -> a) -> b -> [x] -> a
    ```
  */
  mapReduce =
    mapFn: reduceFn: onEmpty: list:
    reduce reduceFn onEmpty (map mapFn list);

  unionOfDisjointList =
    list:
    let
      result =
        mapReduce
          (
            attrs:
            assert builtins.isAttrs attrs;
            {
              conflicts = { };
              values = attrs;
            }
          )
          (a: b: {
            conflicts =
              a.conflicts
              // b.conflicts
              // (builtins.mapAttrs (_: true) (builtins.intersectAttrs a.values b.values));
            values = a.values // b.values;
          })
          {
            conflicts = { };
            values = { };
          }
          list;
      errMsg = "vaculib.unionOfDisjoint: conflict on attrs ${
        lib.concatMapStringsSep ", " lib.strings.escapeNixIdentifier (builtins.attrNames result.conflicts)
      }";
    in
    lib.throwIf (result.conflicts != { }) errMsg result.values;
}
