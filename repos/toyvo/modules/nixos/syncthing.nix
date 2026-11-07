{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.services.syncthing.enable {
    # Allow manual additions to persist across restarts
    services.syncthing.overrideFolders = lib.mkDefault false;
    services.syncthing.overrideDevices = lib.mkDefault false;

    # Open syncthing ports
    networking.firewall = {
      allowedTCPPorts = [
        22000 # Syncthing sync protocol
      ];
      allowedUDPPorts = [
        21027 # Local discovery
        22000 # QUIC sync protocol
      ];
    };
  };
}
