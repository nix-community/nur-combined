{ lib, ... }:

{
  imports = let
    dirEntries = lib.filterAttrs (_: ty: ty == "directory") (builtins.readDir ./.);
  in
    lib.mapAttrsToList (d: _: ./${d}) dirEntries;
}
