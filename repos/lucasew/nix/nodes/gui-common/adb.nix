{pkgs, global, ...}:
let
  inherit (global) username;
in {
  users.users.${username}.extraGroups = [ "adbusers" ];

  programs.adb.enable = true;
  services.udev.packages = with pkgs; [
    gnome3.gnome-settings-daemon
    android-udev-rules
  ];

}
