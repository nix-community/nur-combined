final: prev:
let
  lib = prev.lib;
  ourLib = import ../lib { inherit lib; };
  lib' = lib.recursiveUpdate lib ourLib;
in
lib'.callDirPackageWithRecursive final ../pkgs