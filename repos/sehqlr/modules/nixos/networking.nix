{ config, lib, pkgs, ... }: {
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;
}
