{ inputs, ... }:
{
  flake.modules.nixos.autopeer =
    { config, lib, ... }:
    let
      cfg = config.services.autopeer;
    in
    {
      imports = [ inputs.autopeer.nixosModules.default ];
      services.autopeer.listenAddress = "127.0.0.1";
      realm.workloads.autopeer = {
        # WireGuard and nftables management require the host network/netlink.
        isolation = {
          privateNetwork = false;
          runtimePaths = [ cfg.birdConfDir ];
          allowUnixSockets = [
            "-/run/bird"
            "-/run/systemd/resolve"
          ];
        };
        ingress.http = {
          port = 19341;
          backend = {
            kind = "host-tcp";
            address = "127.0.0.1";
            port = cfg.port;
          };
          service = "autopeer-${config.networking.hostName}";
          allow.identities = [ config.realm.caddy.localID ];
        };
        egress.postgresql = {
          service = "postgresql-autopeer";
          verifyID = "spiffe://nyaw.xyz/service/postgresql";
          socket = "/run/realm/autopeer/egress/.s.PGSQL.5432";
        };
      };
      realm.workloads.caddy = lib.mkIf (config ? caddy) {
        egress.autopeer = {
          service = "autopeer-${config.networking.hostName}";
        };
      };
      systemd.services.autopeer.serviceConfig = {
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateDevices = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        ProtectClock = true;
        ProtectProc = "invisible";
        RestrictSUIDSGID = true;
        RestrictRealtime = true;
        LockPersonality = true;
      };
    };
}
