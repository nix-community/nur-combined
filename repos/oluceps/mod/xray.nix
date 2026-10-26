{
  flake.modules.nixos.xray =
    { lib, config, ... }:
    {
      options.xray.configFile = lib.mkOption {
        type = lib.types.str;
      };
      config = {

        systemd.services.xray.restartIfChanged = false;
        # A public proxy needs host networking; restrict its process and files.
        systemd.services.xray.serviceConfig = {
          ProtectSystem = "strict";
          ProtectHome = true;
          PrivateTmp = true;
          PrivateDevices = true;
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
          ProtectKernelLogs = true;
          ProtectControlGroups = true;
          ProtectClock = true;
          ProtectProc = "invisible";
          RestrictNamespaces = true;
          RestrictSUIDSGID = true;
          RestrictRealtime = true;
          LockPersonality = true;
          SystemCallArchitectures = "native";
          RestrictAddressFamilies = [
            "AF_UNIX"
            "AF_INET"
            "AF_INET6"
            "AF_NETLINK"
          ];
          UMask = "0077";
        };
        networking.firewall.allowedTCPPorts = [ 54432 ];
        services.xray = {
          enable = true;
          settingsFile = config.xray.configFile;
        };
      };
    };
}
