{
  flake.modules.nixos.ncps-client =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      workload = config.realm.workloads.nix-cache;
      enabled = config.realm.enable && workload.enable;
      settings = import ../lib/realm/caddy-ncps.nix { };
      configfile = (pkgs.formats.json { }).generate "realm-ncps-client.json" settings;
      caddy = "${pkgs.caddy}/bin/caddy";
    in
    lib.mkIf config.realm.enable {
      # Nix stays host infrastructure; this dedicated Caddy process exposes its
      # read-only loopback adapter. The egress proxy retains the nix-cache SVID.
      realm.workloads.nix-cache = {
        unit = "realm-ncps-client.service";
        user = "realm-ncps-client";
        group = "realm-ncps-client";
        runtime = "external";
        isolation.privateNetwork = false;
        egress.ncps.service = "ncps";
      };
      environment.etc."realm-ncps-client/config.json" = lib.mkIf enabled {
        source = configfile;
      };
      systemd.services.realm-ncps-client = lib.mkIf enabled {
        description = "Read-only loopback adapter for the Realm Nix cache";
        wantedBy = [ "multi-user.target" ];
        requires = [ "realm-egress-nix-cache-ncps.socket" ];
        after = [
          "systemd-tmpfiles-setup.service"
          "realm-egress-nix-cache-ncps.socket"
        ];
        restartTriggers = [ configfile ];
        serviceConfig = {
          Type = "notify";
          User = workload.user;
          Group = workload.group;
          ExecStartPre = "${caddy} validate --config /etc/realm-ncps-client/config.json";
          ExecStart = "${caddy} run --config /etc/realm-ncps-client/config.json";
          Restart = "on-failure";
          RestartSec = "3s";
          StateDirectory = "realm-ncps-client";
          Environment = [
            "XDG_DATA_HOME=/var/lib/realm-ncps-client"
            "XDG_CONFIG_HOME=/var/lib/realm-ncps-client"
            "HOME=/var/lib/realm-ncps-client"
          ];
          # The standard HTTP transport consults proxy environment variables even
          # for Unix upstreams; keep both dialing and HTTP framing deterministic.
          UnsetEnvironment = [
            "HTTP_PROXY"
            "HTTPS_PROXY"
            "ALL_PROXY"
            "NO_PROXY"
            "http_proxy"
            "https_proxy"
            "all_proxy"
            "no_proxy"
          ];
          # Only the egress directory is exposed from /run. In particular the
          # adapter does not receive the SPIRE Workload API or Caddy admin socket.
          TemporaryFileSystem = [ "/run:ro" ];
          BindReadOnlyPaths = [
            "/run/realm/nix-cache/egress"
            "-/run/systemd/notify"
          ];
          ProtectSystem = "strict";
          ProtectHome = true;
          PrivateDevices = true;
          PrivateTmp = true;
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
          ProtectKernelLogs = true;
          ProtectControlGroups = true;
          ProtectClock = true;
          ProtectHostname = true;
          ProtectProc = "invisible";
          RestrictSUIDSGID = true;
          RestrictRealtime = true;
          RestrictNamespaces = true;
          LockPersonality = true;
          NoNewPrivileges = true;
          CapabilityBoundingSet = [ ];
          AmbientCapabilities = [ ];
          RestrictAddressFamilies = [
            "AF_UNIX"
            "AF_INET"
          ];
          UMask = "0027";
        };
      };
    };
}
