{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.syncthing;
in
{
  config = lib.mkIf cfg.enable {
    # Run syncthing as the hermes user so it has read/write access to the wiki
    services.syncthing.user = lib.mkDefault "hermes";
    services.syncthing.group = lib.mkDefault "hermes";
    services.syncthing.dataDir = lib.mkDefault "/mnt/POOL/hermes/.syncthing";
    services.syncthing.configDir = lib.mkDefault "${cfg.dataDir}/.config/syncthing";

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
