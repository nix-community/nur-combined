{ config, lib, unstable, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    #unstable.zellij

    #unstable.zed-editor
    #etherape
    #cool-retro-term



  ];
}
