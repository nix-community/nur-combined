path:
let
  pkgs = import <nixpkgs> { };
  inherit (builtins) pathExists readDir attrNames;
  kvs =
    if (pathExists path) then
      readDir path
    else
      abort (path + " not found");
  justKs = attrNames kvs;
  fn = k: path + "/${k}";
in
map fn justKs
