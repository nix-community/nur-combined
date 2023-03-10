{ self, lib, ... }:

{
  flake.flakeModules = import ../flake-modules;

  imports = lib.attrValues (import ../flake-modules);
}
