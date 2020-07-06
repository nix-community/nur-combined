with builtins;
let
  lib = (import ../nix).lib;
  userDirs = attrNames (lib.filterAttrs (_: v: v == "directory") (readDir ./.));
  mkUser = u: import (./. + "/${u}");
  users = lib.genAttrs userDirs mkUser;
in
{
  family = with users; [ vincent houbeb ];
} // users
