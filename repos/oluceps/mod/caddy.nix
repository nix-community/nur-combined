{
  flake.modules.nixos.caddy =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      inherit (lib) mkIf;
      cfg = config.caddy;
      format = pkgs.formats.json { };
      configfile = format.generate "config.json" cfg.settings;
    in
    {

      options = {
        caddy = {
          # moved to upper module
          # enable = lib.mkEnableOption "caddy api gateway";
          # mkPackageOption not work here
          expose = lib.mkEnableOption "API env";
          package = lib.mkOption {
            type = lib.types.package;
            default = pkgs.caddy-realm;
            # ;
          };
          settings = lib.mkOption {
            type = lib.types.submodule { freeformType = format.type; };
            default = { };
          };
        };
      };

      config = {
        users.groups.caddy = { };
        users.users.caddy = {
          isSystemUser = true;
          group = "caddy";
        };
        realm.workloads.caddy = {
          spiffeID = config.realm.caddy.localID;
          # Public HTTP/3, ACME and DNS need the host network. Keep the same
          # runtime socket isolation as other systemd workloads.
          isolation = {
            privateNetwork = false;
            runtimePaths = [ "/run/caddy" ];
            allowUnixSockets = [ "-/run/systemd/resolve" ];
          };
        };
        realm.observability.endpoints.caddy.port = 20242;
        vaultix.secrets.caddy = { };
        networking.firewall = lib.mkIf (!config.data.node.${config.networking.hostName}.nat) {
          allowedTCPPorts = [
            80
            443
          ];
          allowedUDPPorts = [ 443 ];
        };
        caddy.settings = {
          admin = {
            listen = "unix//run/caddy/admin.sock|0600";
            config.persist = false;
          };
          # logging.logs.debug.level = "debug";
          storage = mkIf cfg.expose {
            module = "s3";
            prefix = "ssl";
            insecure = false;
          };
          apps = {
            http.servers.observability = {
              listen = [ "127.0.0.1:20242" ];
              automatic_https.disable = true;
              routes = [ { handle = [ { handler = "metrics"; } ]; } ];
            };

            http.metrics = { };
            http.grace_period = "1s";
            http.servers.srv0 = {
              listen = [ ":443" ];
              strict_sni_host = false;
              automatic_https = {
                skip_certificates = [
                ];
              };
            };
          };
        };

        environment.etc."caddy/config.json".source = configfile;
        environment.systemPackages = [ cfg.package ];

        systemd.services.caddy = {
          preStart = "cp -f /etc/caddy/config.json /var/lib/caddy/backup.json";
          unitConfig = {
            StartLimitIntervalSec = 0;
          };
          serviceConfig =
            let
              caddyBin = "${cfg.package}/bin/caddy";
            in
            {
              Type = "notify";
              # Public entrypoints initialize their shared S3 certificate store.
              TimeoutStartSec = "5min";
              ExecStartPre = "${caddyBin} validate --config /etc/caddy/config.json";
              ExecStart = "${caddyBin} run --config /etc/caddy/config.json";
              ExecReload = "${caddyBin} reload --force --config /etc/caddy/config.json";
              DynamicUser = true;
              User = "caddy";
              Group = "caddy";
              StateDirectory = "caddy";
              RuntimeDirectory = "caddy";
              RuntimeDirectoryMode = "0700";
              ProtectSystem = "strict";
              ProtectHome = true;
              PrivateDevices = true;
              ProtectKernelTunables = true;
              ProtectKernelModules = true;
              ProtectKernelLogs = true;
              ProtectControlGroups = true;
              ProtectClock = true;
              ProtectHostname = true;
              ProtectProc = "invisible";
              RestrictSUIDSGID = true;
              RestrictRealtime = true;
              LockPersonality = true;
              AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
              CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
              UMask = "0027";
              Environment = [
                "XDG_DATA_HOME=%S"
                "XDG_CONFIG_HOME=%S/caddy"
                "HOME=%S/caddy"
              ];
              Restart = "always";
              EnvironmentFile = mkIf cfg.expose config.vaultix.secrets.caddy.path;
              LoadCredential = mkIf (!cfg.expose) (
                (map (config.fn.genCredPath)) [
                  "nyaw.cert"
                  "nyaw.key"
                ]
              );
              RestartSec = 1;
            };
          wantedBy = [ "multi-user.target" ];
          after = [
            "network.target"
            "network-online.target"
            "systemd-tmpfiles-setup.service"
            "coredns.service"
          ];
          wants = [ "coredns.service" ];
          requires = [ "network-online.target" ];
          reloadTriggers = [ configfile ];
        };
      };
    };
}
