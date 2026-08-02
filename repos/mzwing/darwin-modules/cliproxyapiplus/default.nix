moduleArgs @ {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.cliproxyapiplus;
  serviceLib = import ../../internal/system-service {inherit lib pkgs;};
  cliproxyapiplus = import ../../modules/cliproxyapiplus (moduleArgs // {inherit serviceLib;});
  accountIdType = lib.types.ints.between 502 2147483647;

  service = cliproxyapiplus.mkService {
    account.darwin = {
      uid = cfg.uid;
      gid = cfg.gid;
    };
    darwin = {
      standardOutPath = "${cfg.dataDir}/cliproxyapiplus.out.log";
      standardErrorPath = "${cfg.dataDir}/cliproxyapiplus.err.log";
    };
  };
in {
  options.services.cliproxyapiplus =
    cliproxyapiplus.options
    // {
      uid = lib.mkOption {
        type = accountIdType;
        default = 537;
        description = ''
          UID of the hidden `_cliproxyapiplus` service account. Override this
          if the default conflicts with an existing local account.
        '';
      };

      gid = lib.mkOption {
        type = accountIdType;
        default = 537;
        description = ''
          GID of the `_cliproxyapiplus` service group. Override this if the
          default conflicts with an existing local group.
        '';
      };
    };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    cliproxyapiplus.sharedConfig
    (serviceLib.mkDarwin service)
  ]);
}
