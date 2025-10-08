{ lib }:
with lib;
rec {
  /**
    Recursively collects all values from a nested attribute set into a single list.

    @param attrset The attribute set to traverse.
    @return A list containing all the values from the attribute set.

    Example:
    recursiveValuesToList {
      a = 1;
      b = {
        c = 2;
        d = "hello";
      };
      e = [ 3 4 ];
    }
    => [ 1 2 "hello" [ 3 4 ] ]
  */
  recursiveValuesToList = attrset:
    let
      values = builtins.attrValues attrset;
    in
    builtins.concatLists (map
      (value:
        if builtins.isAttrs value then
          recursiveValuesToList value
        else
          [ value ]
      )
      values);

  # Recursively flattens an attribute set.
  # Example:
  #   flattenAttrset {
  #     a.b = 1;
  #     c.d = 2;
  #   }
  #   => { b = 1; d = 2; }
  flattenAttrset = attrs:
    foldl'
      (acc: name:
        let
          value = attrs.${name};
        in
        if isAttrs value && !(isDerivation value) then
          acc // flattenAttrset value
        else
          acc // { ${name} = value; }
      )
      { }
      (builtins.attrNames attrs);

  fromDirectoryRecursive = { directory, filename, transformer, ... }@args:
    let
      inherit (lib.path) append;
      inherit (lib) concatMapAttrs;
      defaultPath = append directory filename;
    in
    if builtins.pathExists defaultPath then
    # if `${directory}/${filename}` exists, call it directly
      transformer defaultPath
    else
      concatMapAttrs
        (
          name: type:
            # for each directory entry
            let
              path = append directory name;
            in
            if type == "directory" then
              {
                # recurse into directories
                "${name}" = fromDirectoryRecursive (
                  args
                  // {
                    directory = path;
                  }
                );
              }
            else
              {
                # ignore files
              }
        )
        (builtins.readDir directory);
}
