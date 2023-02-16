{ pkgs, ... }:

{
  home.packages = [ pkgs.keybase-gui ];
  services = {
    kbfs.enable = true;
    keybase.enable = true;
  };
}
