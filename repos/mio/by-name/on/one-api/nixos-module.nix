# by-name/on/one-api/nixos-module.nix
#
# One API is a self-hosted LLM gateway: it stores upstream provider API keys and
# issues its own access tokens, so its database is a high-value secret.  The
# service therefore runs as an unprivileged dynamic user, keeps its state in
# /var/lib/one-api with a 0077 umask, and does not open the firewall by default.
#
# one-api speaks plain HTTP only.  Put it behind a TLS terminating reverse proxy
# (nginx, Caddy, ...) and leave openFirewall = false unless a proxy or a private
# network provides the front door.

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.one-api;
  dataDir = "/var/lib/one-api";
in
{
  options.services.one-api = {
    enable = lib.mkEnableOption "One API, an LLM API gateway and key management service";

    package = lib.mkPackageOption pkgs "one-api" { };

    port = lib.mkOption {
      type = lib.types.port;
      default = 3000;
      description = ''
        TCP port one-api listens on.  one-api binds all interfaces; restrict
        reachability with the firewall or a reverse proxy.
      '';
    };

    theme = lib.mkOption {
      type = lib.types.enum [
        "default"
        "berry"
        "air"
      ];
      default = "default";
      description = "Bundled web UI theme.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Open {option}`port` in the firewall.  one-api serves plain HTTP, so only
        enable this when something in front of it (a TLS proxy or a trusted
        private network) protects the traffic.
      '';
    };

    environment = lib.mkOption {
      type = with lib.types; attrsOf str;
      default = { };
      example = {
        MEMORY_CACHE_ENABLED = "true";
        SYNC_FREQUENCY = "60";
      };
      description = ''
        Extra non-secret environment variables for one-api.

        This attribute set is written to the world-readable Nix store.  Secrets
        such as `SESSION_SECRET`, `INITIAL_ROOT_TOKEN`,
        `INITIAL_ROOT_ACCESS_TOKEN`, database DSNs with passwords,
        `REDIS_CONN_STRING`, `SMTP_TOKEN`, `GITHUB_CLIENT_SECRET`,
        `OIDC_CLIENT_SECRET` and provider keys must go into
        {option}`environmentFile` instead (provider keys are better added in the
        web UI, where they are stored in the database).
      '';
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "/run/secrets/one-api.env";
      description = ''
        Environment file with one `KEY=VALUE` per line, read by systemd before it
        drops privileges.  Because systemd reads it as root, the file may be
        root-owned with mode 0400 and does not have to be world-readable.

        Set at least `SESSION_SECRET` so logins survive a restart; one-api
        otherwise generates a random key on every start.  one-api creates a
        `root` / `123456` account on a fresh database; change that password
        after the first login.  `INITIAL_ROOT_ACCESS_TOKEN` and
        `INITIAL_ROOT_TOKEN` pre-seed the root management/API tokens, but do
        not replace the password.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

    systemd.services.one-api = {
      description = "One API LLM API gateway";
      documentation = [ "https://github.com/songquanpeng/one-api" ];
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      environment = {
        SQLITE_PATH = "${dataDir}/one-api.db";
        # one-api downloads tiktoken encodings at startup unless this is set;
        # keep the cache in the state directory so restarts do not need network.
        TIKTOKEN_CACHE_DIR = "${dataDir}/tiktoken-cache";
        THEME = cfg.theme;
      }
      // cfg.environment;

      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        StateDirectory = "one-api";
        StateDirectoryMode = "0700";
        WorkingDirectory = dataDir;
        ExecStart = lib.escapeShellArgs [
          (lib.getExe cfg.package)
          "--port"
          (toString cfg.port)
          "--log-dir"
          "${dataDir}/logs"
        ];
        EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;

        Restart = "always";
        RestartSec = 5;
        UMask = "0077";

        # Hardening.  SystemCallFilter is @system-service minus the sets an HTTP
        # server never needs; if a future Go toolchain trips over it (EPERM or
        # SIGSYS in the journal), add the missing set here rather than dropping
        # the filter.  SystemCallErrorNumber reports denials as EPERM instead of
        # killing the process, which makes such regressions debuggable.
        NoNewPrivileges = true;
        CapabilityBoundingSet = "";
        AmbientCapabilities = "";
        SystemCallFilter = [
          "@system-service"
          "~@clock @cpu-emulation @debug @module @mount @obsolete @privileged @raw-io @reboot @resources @swap"
        ];
        SystemCallErrorNumber = "EPERM";
        # No JIT in the Go backend or cgo SQLite; if a future dependency needs
        # W^X regions this has to be dropped for that dependency.
        MemoryDenyWriteExecute = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        PrivateMounts = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        ProtectClock = true;
        ProtectHostname = true;
        ProtectProc = "invisible";
        ProcSubset = "pid";
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        LockPersonality = true;
        RemoveIPC = true;
        SystemCallArchitectures = "native";
      };
    };

    warnings =
      lib.optional (cfg.environmentFile == null && !(cfg.environment ? SESSION_SECRET)) ''
        services.one-api: no SESSION_SECRET is configured. one-api will generate a
        random session key at every start, invalidating all logins on restart.
        Set SESSION_SECRET in services.one-api.environmentFile (or environment).
      ''
      ++ lib.optional cfg.openFirewall ''
        services.one-api: openFirewall is enabled but one-api serves plain HTTP.
        Make sure the port is only reachable through a TLS terminating reverse
        proxy or a trusted private network.
      '';
  };
}
