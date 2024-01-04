{ lib, config, ... }:

let
  inherit (lib) types pipe attrNames attrValues filter mapAttrs mkOption;
in
{
  options = {
    services.syncthing.folder-targets = mkOption {
      description = "Folders mapped outside the data directory";

      type = types.attrsOf (types.nullOr (types.path));
    };
  };

  config =
  lib.mkIf config.services.syncthing.enable {
    services.syncthing = {
      group = "users";
      overrideFolders = lib.mkDefault false;
      overrideDevices = lib.mkDefault false;
      guiAddress = "127.0.0.1:${toString config.networking.ports.syncthing-gui.port}";
    };

    networking.ports.syncthing-gui.enable = true;

    systemd.mounts = pipe config.services.syncthing.folder-targets [
      (mapAttrs (k: v: {
        what = v;
        where = "${config.services.syncthing.dataDir}/${k}";
        type = "none";
        options = "bind";
        startLimitBurst = 3;
        startLimitIntervalSec = 10;
        requiredBy = [ "syncthing.service" ];
        mountConfig = {
          DirectoryMode = "0777";
        };
      }))
      (attrValues)
    ];

    services.syncthing.settings.folders = pipe config.services.syncthing.folder-targets [
      (mapAttrs (k: v: {
        path = "${config.services.syncthing.dataDir}/${k}";
      }))
      # (attrValues)
    ];

    services.nginx.virtualHosts."syncthing.${config.networking.hostName}.${config.networking.domain}" = {
      locations."/" = {
        proxyPass = "http://${config.services.syncthing.guiAddress}";
        proxyWebsockets = true;
      };
    };
  };
}
