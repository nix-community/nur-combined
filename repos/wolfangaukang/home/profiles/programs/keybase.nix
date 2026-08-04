{ pkgs, ... }:

# This will create a full setup to use Keybase
{
  home.packages = [ pkgs.keybase-gui ];
  services = {
    kbfs.enable = true;
    keybase.enable = true;
  };
}
