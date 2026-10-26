{
  flake.modules.nixos.atuin =
    { config, ... }:
    {
      realm.workloads.atuin = {
        ingress.http = {
          port = 18888;
          backend = {
            kind = "private-tcp";
            port = 8888;
          };
          service = "atuin";
          allow.identities = config.realm.caddy.allowedIDs.atuin;
        };
      };

      services.atuin = {
        enable = true;
        host = "127.0.0.1";
        port = 8888;
        openFirewall = false;
        openRegistration = false;
        maxHistoryLength = 65536;
        database.uri = "postgresql://atuin@localhost/atuin?host=/run/postgresql&sslmode=disable";
      };
      systemd.services.atuin = {
        after = [ "postgresql.target" ];
        requires = [ "postgresql.target" ];
        serviceConfig = {
          BindReadOnlyPaths = [ "/run/postgresql" ];
          Restart = "on-failure";
          RestartSec = "5s";
        };
      };
    };
}
