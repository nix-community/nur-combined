{ config ? {}, lib, pkgs, ... }:
let
  hm = (import ../../.. {}).hm;
in
{
  imports = lib.attrValues hm.rawModules;

  home.packages = hm.base ++ (with pkgs; [
    vscode
  ]);

  programs.dev.enable = true;
  programs.base.enable = true;
}
