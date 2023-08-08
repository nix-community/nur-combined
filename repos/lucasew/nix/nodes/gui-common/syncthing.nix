{ lib, config, ... }:

lib.mkIf config.services.syncthing.enable {
  services.syncthing = {
    overrideFolders = lib.mkDefault false;
    overrideDevices = lib.mkDefault false;
    guiAddress = "127.0.0.1:${toString config.networking.ports.syncthing-gui.port}";
    relay.enable = true;
  };

  networking.ports.syncthing-gui.enable = true;

  services.nginx.virtualHosts."syncthing.${config.networking.hostName}.${config.networking.domain}" = {
    locations."/" = {
      proxyPass = "http://${config.services.syncthing.guiAddress}";
      proxyWebsockets = true;
    };
  };
}
