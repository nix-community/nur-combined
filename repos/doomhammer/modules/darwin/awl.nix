{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.awl;
in
{
  options.services.awl = {
    enable = mkEnableOption "Anywherelan service.";

    package = mkOption {
      type = types.package;
      default = pkgs.awl;
      defaultText = "pkgs.awl";
      description = ''
        The awl package to use.
      '';
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/anywherelan";
      description = ''
        Runtime state directory used as AWL_DATA_DIR. AWL stores config_awl.json,
        identity material, peer state, and peerstore data here.
      '';
    };

    installPackage = mkOption {
      type = types.bool;
      default = true;
      description = "Add the AWL package to environment.systemPackages for CLI usage.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = mkIf cfg.installPackage [ cfg.package ];

    launchd.daemons.awl = {
      path =
        with pkgs;
        [
          coreutils
          openresolv
        ]
        ++ [ "/sbin" ];

      script = ''
        mkdir -p ${cfg.dataDir}
        exec ${cfg.package}/bin/awl
      '';

      environment = {
        AWL_DATA_DIR = cfg.dataDir;
      };

      serviceConfig =
        let
          #FIXME
          logPath = "/var/log/awl.log";
        in
        {
          RunAtLoad = true;
          KeepAlive = true;
          StandardOutPath = logPath;
          StandardErrorPath = logPath;
        };
    };
  };
}
