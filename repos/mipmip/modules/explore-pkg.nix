{ config, lib, unstable, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    #unstable.zellij

    #unstable.zed-editor
    #etherape
    #cool-retro-term
    rclone
    rclone-browser
#    matterbridge

    #distrobox
#    gnome.gnome-boxes


  ];
}
