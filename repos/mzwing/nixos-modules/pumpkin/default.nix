moduleArgs @ {
  config,
  lib,
  pkgs,
  utils,
  ...
}: let
  cfg = config.services.pumpkin;
  serviceLib = import ../../internal/system-service {
    inherit lib pkgs;
    systemdUtils = utils;
  };
  pumpkin = import ../../modules/pumpkin (moduleArgs // {inherit serviceLib;});

  service = pumpkin.mkService {
    nixos = {
      wants = ["network-online.target"];
      after = ["network-online.target"];
      serviceConfig =
        import ../../internal/system-service/systemd-hardening.nix
        // {
          ReadWritePaths = [cfg.dataDir];
        };
    };
  };
in {
  options.services.pumpkin = pumpkin.options;

  config = lib.mkIf cfg.enable (lib.mkMerge [
    pumpkin.sharedConfig
    (serviceLib.mkNixos service)
  ]);
}
