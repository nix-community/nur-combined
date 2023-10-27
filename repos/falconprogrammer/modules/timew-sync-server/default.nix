{config, lib, pkgs, ...}:
let
  cfg = config.services.timew-sync-server;
in
{
  options.services.timew-sync-server = {
    enable = mkEnableOption "timew-sync-server";

    port = mkOption {
      type = types.int;
      default = 8080;
      description = "The port on which the timew-sync-server listens.";
    };
  };

  config = mkIf cfg.enable {
    users.users.timew-sync-server = {
      description = "User for the timew-sync-server service";
      isSystemUser = true;
      group = "timew-sync-server";
    };

    systemd.services.timew-sync-server = {
      description = "timew-sync-server";
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        User = "timew-sync-server";
        Group = "timew-sync-server";
        Restart = "on-failure";
        StateDirectory = "timew-sync-server";

        ExecStart = "${pkgs.timew-sync-server}/bin/timew-sync-server --port ${toString cfg.port} --keys-location ${lib.mkPath "$STATE_DIRECTORY/authorized_keys"} --sqlite-db $STATE_DIRECTORY/db.sqlite";
        Type = "simple";
      };
    };
  };

}
