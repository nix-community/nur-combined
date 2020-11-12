{pkgs, config, ... }:
let
  globalConfig = import <dotfiles/globalConfig.nix>;
in
{
  programs.adb.enable = true;
  services.udev.packages = [
    pkgs.android-udev-rules
  ];
  users.users.${globalConfig.username}.extraGroups = [ "adbusers" ];
}
