{ config, lib, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    glxinfo
    lm_sensors
  ];
}




