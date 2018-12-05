{ config ? {}, lib, pkgs, ... }:
let
  hm = (import ../../.. {}).hm;
in
{
  imports = lib.attrValues hm.rawModules;

  home.packages = hm.base;

  services.syncthing.enable = true;
}
