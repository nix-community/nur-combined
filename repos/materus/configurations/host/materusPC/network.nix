{ config, pkgs, lib, inputs, materusFlake, ... }:
{
  networking.useDHCP = lib.mkDefault true;
  networking.hostName = "materusPC";
  networking.wireless.iwd.enable = true;
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 24800 5900 5357 4656 8080 9943 9944];
  networking.firewall.allowedUDPPorts = [ 24800 5900 3702 4656 6000 9943 9944];
  #Fix warning
  networking.networkmanager.extraConfig = lib.mkDefault ''
    [connectivity]
    uri=http://nmcheck.gnome.org/check_network_status.txt
  '';


}
