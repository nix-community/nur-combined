{ config ? {}, lib, pkgs, ... }:
let
  self = (import ../../.. {});
  hm = self.hm;
in
{
  imports = lib.attrValues hm.rawModules;

  home.packages = hm.base ++ [
    # pkgs.slack
  ];

  services.keybase.enable = true;
  services.kbfs.enable = true;

  programs.bash.enable = true;

  home.file = self.lib.buildDesktops [
  {
    name = "Slack";
    package = pkgs.slack;
  }
  {
    name = "VSCode";
    package = pkgs.vscode;
  }
  ];
}
