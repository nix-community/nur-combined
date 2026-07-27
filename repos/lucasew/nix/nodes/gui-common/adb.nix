{
  pkgs,
  global,
  ...
}:
let
  inherit (global) username;
in
{
  users.users.${username}.extraGroups = [ "adbusers" ];
  services.udev.packages = with pkgs; [
    gnome-settings-daemon
  ];
  environment.systemPackages = [ pkgs.android-tools ];
}
