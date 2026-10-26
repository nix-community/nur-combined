{
  flake.modules.nixos.subs =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.subs.scriptPath = lib.mkOption {
        type = lib.types.str;
        default = config.vaultix.secrets.subs.path;
      };
      config = {
        realm.workloads.subs = {
          ingress.http = {
            port = 18004;
            backend = {
              kind = "private-tcp";
              address = "::1";
              port = 8004;
            };
            service = "subs";
            allow.identities = config.realm.caddy.allowedIDs.subs;
          };
          http.internet = true;
        };
        realm.workloads.caddy = lib.mkIf (config ? caddy) {
          egress.subs = {
            service = "subs";
          };
        };
        systemd.services.subs = {
          unitConfig.StartLimitIntervalSec = 0;
          serviceConfig.Type = "simple";
          serviceConfig = {
            User = "subs";
            Group = "subs";
            StateDirectory = "subs";
            WorkingDirectory = "/var/lib/subs";
            ProtectSystem = "strict";
            ProtectHome = true;
            PrivateDevices = true;
            LoadCredential = [ "main.ts:${config.subs.scriptPath}" ];
          };
          serviceConfig.ExecStart = "${lib.getExe pkgs.deno} run --allow-env --allow-net --no-check \${CREDENTIALS_DIRECTORY}/main.ts";
          environment = {
            DENO_DIR = "/var/lib/subs/deno";
          };
          serviceConfig.Restart = "always";
          serviceConfig.RestartSec = 1;
          wantedBy = [ "multi-user.target" ];
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
        };
      };
    };
}
