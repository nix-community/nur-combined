{ lib }: rec {

  # RFC952, B. Lexical grammar, <hname>
  hostname = lib.mkOptionType {
    name = "hostname";
    check = x: lib.isString x && lib.all label.check (lib.splitString "." x);
    merge = lib.mergeOneOption;
  };

  # RFC952, B. Lexical grammar, <name>
  # RFC1123, 2.1  Host Names and Numbers
  label = lib.mkOptionType {
    name = "label";
    # TODO case-insensitive labels
    check = lib.test "[0-9A-Za-z]([0-9A-Za-z-]*[0-9A-Za-z])?";
    merge = lib.mergeOneOption;
  };

  # POSIX.1‐2013, 3.278 Portable Filename Character Set
  filename = lib.mkOptionType {
    name = "POSIX filename";
    check = lib.test "([0-9A-Za-z._])[0-9A-Za-z._-]*";
    merge = lib.mergeOneOption;
  };

  # POSIX.1‐2013, 3.2 Absolute Pathname
  absolute-pathname = lib.mkOptionType {
    name = "POSIX absolute pathname";
    check = x: lib.isString x && lib.substring 0 1 x == "/" && pathname.check x;
    merge = lib.mergeOneOption;
  };

  # POSIX.1‐2013, 3.267 Pathname
  pathname = lib.mkOptionType {
    name = "POSIX pathname";
    check = x:
      let
        # The filter is used to normalize paths, i.e. to remove duplicated and
        # trailing slashes.  It also removes leading slashes, thus we have to
        # check for "/" explicitly below.
        xs = lib.filter (s: lib.stringLength s > 0) (lib.splitString "/" x);
      in
        lib.isString x && (x == "/" || (lib.length xs > 0 && lib.all filename.check xs));
    merge = lib.mergeOneOption;
  };

  # POSIX.1-2013, 3.431 User Name
  username = lib.mkOptionType {
    name = "POSIX username";
    check = filename.check;
    merge = lib.mergeOneOption;
  };

}
