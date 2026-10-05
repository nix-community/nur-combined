{
  callPackage,
  lib,
}:

(lib.mapAttrs' (dirname: _type: {
  name = dirname;
  value = (callPackage (./. + "/${dirname}") { });
}) (lib.filterAttrs (_: filetype: filetype == "directory") (builtins.readDir ./.)))
// { }
