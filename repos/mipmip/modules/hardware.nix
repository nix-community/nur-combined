{ config, lib, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    dmidecode
    pciutils
    glxinfo
    lm_sensors
  ];
}




