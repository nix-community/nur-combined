{ ... }:

{
  networking = {
    firewall = {
      enable = false;
      allowedTCPPorts = [
        23561 # F;sskjfd
      ];
      allowedUDPPorts = [ ];
    };
    networkmanager.enable = true;
  };
  users.extraGroups.networkmanager.members = [ "bjorn" ];
}
