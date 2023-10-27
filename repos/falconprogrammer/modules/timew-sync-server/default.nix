{config, lib, pkgs, ...}:
let
  cfg = config.services.timew-sync-server;
in
{
  options.services.timew-sync-server = {
    enable = lib.mkEnableOption "timew-sync-server";

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/timew-sync-server";
      description = "The directory where the timew-sync-server stores its data.";
    };

    port = lib.mkOption {
      type = lib.types.int;
      default = 8080;
      description = "The port on which the timew-sync-server listens.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.timew-sync-server = {
      description = "User for the timew-sync-server service";
      isSystemUser = true;
      group = "timew-sync-server";
    };

    systemd.services.timew-sync-server = {
      description = "timew-sync-server";
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      preStart = ''
        mkdir -p 0770 ${cfg.dataDir}/authorized_keys
        chown -R timew-sync-server:timew-sync-server ${cfg.dataDir}
      '';

      serviceConfig = {
        User = "timew-sync-server";
        Group = "timew-sync-server";
        Restart = "on-failure";

        ExecStart = "${pkgs.timew-sync-server}/bin/timew-sync-server --port ${toString cfg.port} --keys-location ${cfg.dataDir}/authorized_keys --sqlite-db ${cfg.dataDir}/db.sqlite";
        Type = "simple";
      };
    };
  };

}
