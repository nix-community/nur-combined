{ config, lib, pkgs, ... }:

{

  programs.adb.enable = true;
  users.users.pim.extraGroups = ["adbusers"];
  environment.systemPackages = with pkgs; [
    android-tools
  ];
}

