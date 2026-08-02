moduleArgs @ {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.pumpkin;
  serviceLib = import ../../internal/system-service {inherit lib pkgs;};
  pumpkin = import ../../modules/pumpkin (moduleArgs // {inherit serviceLib;});
  accountIdType = lib.types.ints.between 502 2147483647;

  service = pumpkin.mkService {
    account.darwin = {
      uid = cfg.uid;
      gid = cfg.gid;
    };
    darwin = {
      standardOutPath = "${cfg.dataDir}/pumpkin.out.log";
      standardErrorPath = "${cfg.dataDir}/pumpkin.err.log";
    };
  };
in {
  options.services.pumpkin =
    pumpkin.options
    // {
      uid = lib.mkOption {
        type = accountIdType;
        default = 536;
        description = ''
          UID of the hidden `_pumpkin` service account. Override this if the
          default conflicts with an existing local account.
        '';
      };

      gid = lib.mkOption {
        type = accountIdType;
        default = 536;
        description = ''
          GID of the `_pumpkin` service group. Override this if the default
          conflicts with an existing local group.
        '';
      };
    };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    pumpkin.sharedConfig
    (serviceLib.mkDarwin service)
  ]);
}
