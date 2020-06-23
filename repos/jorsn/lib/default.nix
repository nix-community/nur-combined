{ pkgs }:

let
  inherit (pkgs) lib;
  lib' = lib // libD;
  callLibs = file: import file { lib = lib'; };

  libD = { inherit jorsn; } // {
    inherit (jorsn.attrsets) setAttrs;

    inherit (jorsn.bool) is;
    inherit (jorsn.functional) compose;

    inherit (jorsn.filesystem)
      isRegular isDir isHidden isSymlink isNixFile fileName dirName
      dirPaths listDir fileType listNixDirTrees listNixDirTree listNixDirTree';

    inherit (jorsn.lists) cons;

    inherit (jorsn.strings) strip;
  };

  jorsn = {
    attrsets = {
      setAttrs = names: b: lib.genAttrs names (a: b);
    };

    bool = {
      is = a: b: a == b; # apply partially
    };

    functional = {
      compose = f: g: x: f (g x);
    };


    filesystem = callLibs ./filesystem.nix;

    lists = {
      cons = a: as: [a] ++ as; # apply partially
    };

    strings = {
      getPname = pkg: pkg.pname or lib.getName pkg;
      strip = let
        fromNullOr = default: n: if n == null then default else n;
        headSafe = default: list: if lib.length list == 0 then default else lib.head list;
        match = builtins.match "[[:space:]]*([^[:space:]](.*[^[:space:]])?)[[:space:]]*";
      in s: headSafe "" (fromNullOr [] match s);
    };
  };
in lib'
