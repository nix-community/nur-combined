moduleArgs @ {
  config,
  lib,
  pkgs,
  utils,
  ...
}: let
  cfg = config.services.cliproxyapiplus;
  serviceLib = import ../../internal/system-service {
    inherit lib pkgs;
    systemdUtils = utils;
  };
  cliproxyapiplus = import ../../modules/cliproxyapiplus (moduleArgs // {inherit serviceLib;});

  service = cliproxyapiplus.mkService {
    nixos = {
      wants = ["network-online.target"];
      after = ["network-online.target"];
      serviceConfig = {
        CapabilityBoundingSet = [""];
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectControlGroups = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        ReadWritePaths = [cfg.dataDir];
        RestrictSUIDSGID = true;
      };
    };
  };
in {
  options.services.cliproxyapiplus = cliproxyapiplus.options;

  config = lib.mkIf cfg.enable (lib.mkMerge [
    cliproxyapiplus.sharedConfig
    (serviceLib.mkNixos service)
  ]);
}
