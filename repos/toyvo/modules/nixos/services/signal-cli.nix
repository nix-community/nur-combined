{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.signal-cli;
in
{
  options.services.signal-cli = {
    enable = lib.mkEnableOption "signal-cli HTTP daemon";

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Address for the signal-cli HTTP daemon";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8181;
      description = "Port for the signal-cli HTTP daemon";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/signal-cli";
      description = "Directory for signal-cli account data and keys";
    };

    environmentFile = lib.mkOption {
      type = lib.types.path;
      description = "Environment file supplying SIGNAL_ACCOUNT (e.g. the hermes.env sops secret)";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.signal-cli = {
      isSystemUser = true;
      group = "signal-cli";
    };
    users.groups.signal-cli = { };

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0700 signal-cli signal-cli -"
    ];

    systemd.services.signal-cli = {
      description = "signal-cli HTTP daemon";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        User = "signal-cli";
        Group = "signal-cli";
        EnvironmentFile = cfg.environmentFile;
        Restart = "always";
        RestartSec = "5s";
      };
      script = ''
        exec ${lib.getExe pkgs.signal-cli} \
          --config ${cfg.dataDir} \
          --account "$SIGNAL_ACCOUNT" \
          daemon \
          --http ${cfg.host}:${toString cfg.port}
      '';
    };
  };
}
