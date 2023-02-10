{ ... }:

let
  brume = "10.11.12";

in {
  networking = {
    hosts = {
      "${brume}.112" = [ "grimsnes" ];
      "${brume}.203" = [ "surtsey" ];
    };
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
