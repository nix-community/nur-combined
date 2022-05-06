{ pkgs, ... }:

{
  home = {
    file.".config/ranger/rc.conf".source = ../../../misc/dotfiles/config/ranger/rc.conf;
    packages = [ pkgs.ranger ];
  };
}
