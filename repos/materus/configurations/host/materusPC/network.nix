{ config, pkgs, lib, inputs, materusFlake, ... }:
{
  networking.useDHCP = lib.mkDefault true;
  networking.hostName = "materusPC";
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 24800 5900 5357 4656 ];
  networking.firewall.allowedUDPPorts = [ 24800 5900 3702 4656 ];

  #Fix warning
  networking.networkmanager.extraConfig = lib.mkDefault ''
    [connectivity]
    uri=http://nmcheck.gnome.org/check_network_status.txt
  '';


}
