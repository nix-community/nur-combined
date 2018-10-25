{ lib, ... }:
with lib;
rec {

  haskell.conid = mkOptionType {
    name = "Haskell constructor identifier";
    check = test "[[:upper:]][[:lower:]_[:upper:]0-9']*";
    merge = mergeOneOption;
  };

  haskell.modid = mkOptionType {
    name = "Haskell module identifier";
    check = x: isString x && all haskell.conid.check (splitString "." x);
    merge = mergeOneOption;
  };

  # POSIX.1‐2013, 3.2 Absolute Pathname
  absolute-pathname = mkOptionType {
    name = "POSIX absolute pathname";
    check = x: isString x && substring 0 1 x == "/" && pathname.check x;
    merge = mergeOneOption;
  };

  file-mode = mkOptionType {
    name = "file mode";
    check = test "[0-7]{4}";
    merge = mergeOneOption;
  };

  # POSIX.1‐2013, 3.278 Portable Filename Character Set
  filename = mkOptionType {
    name = "POSIX filename";
    check = test "([0-9A-Za-z._])[0-9A-Za-z._-]*";
    merge = mergeOneOption;
  };

  # POSIX.1‐2013, 3.267 Pathname
  pathname = mkOptionType {
    name = "POSIX pathname";
    check = x:
      let
        # The filter is used to normalize paths, i.e. to remove duplicated and
        # trailing slashes.  It also removes leading slashes, thus we have to
        # check for "/" explicitly below.
        xs = filter (s: stringLength s > 0) (splitString "/" x);
      in
        isString x && (x == "/" || (length xs > 0 && all filename.check xs));
    merge = mergeOneOption;
  };

}
