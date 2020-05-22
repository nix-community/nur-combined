{ pkgs, ... }:

{
  imports = [ ./base.nix ];
  machine.base.fedora = true;
  programs = {
    man.enable = false;
  };
  profiles.bash.enable = false;
  home.extraOutputsToInstall = [ "man" ];
}
