{ lib, ... }:
rec {
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
  mapNamesToAttrs =
    f: list:
    mapListToAttrs (name: {
      inherit name;
      value = f name;
    }) list;

  /**
    # Type

    ```
    mapNamesToAttrsConst :: a -> [${name}] -> { ${name} :: a; }
    ```
  */
  mapNamesToAttrsConst = a: list: mapNamesToAttrs (_: a) list;

  /**
    # Type
    ```
    isListWhere :: (a -> Bool) -> [a] -> Bool
    isListWhere :: (a -> Bool) -> b -> Bool
    ```
  */
  isListWhere = f: list: lib.isList list && lib.all f list;
}
