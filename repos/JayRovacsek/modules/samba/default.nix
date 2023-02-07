{ config, pkgs, ... }:
let
  hostname = config.networking.hostName;
  sambaConfig = import ./. + "/configs/${hostname}.nix";
in {
  services.samba = sambaConfig;

  firewall = {
    allowedTCPPorts = [ 139 445 ];
    allowedUDPPorts = [ 137 138 ];
  };
}
