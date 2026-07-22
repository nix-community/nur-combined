{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.scrobblex;
  pkg = cfg.package;
  # The app resolves static/, views/, favicon.ico and the OAuth data dir all
  # relative to process.cwd().  We set WorkingDirectory to the writable state
  # directory and symlink the read-only store assets in on startup.
  stateDir = "/var/lib/scrobblex";
in {
  options.services.scrobblex = {
    enable = lib.mkEnableOption "Scrobblex Plex-to-Trakt scrobbler";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.nur.repos.msaxena.scrobblex;
      defaultText = lib.literalExpression "pkgs.nur.repos.msaxena.scrobblex";
      description = "The scrobblex package to use.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 3090;
      description = "TCP port scrobblex listens on.";
    };

    logLevel = lib.mkOption {
      type = lib.types.enum ["error" "warn" "info" "http" "verbose" "debug" "silly"];
      default = "info";
      description = "Winston log level.";
    };

    plexUser = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      example = ["alice" "bob"];
      description = ''
        Plex usernames whose webhook events are accepted.
        An empty list (the default) allows all users through.
      '';
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "/run/secrets/scrobblex";
      description = ''
        Path to a file containing secret environment variables, loaded by
        systemd before the service starts.  Must define at minimum:

          TRAKT_ID=your-trakt-client-id
          TRAKT_SECRET=your-trakt-client-secret

        Use sops-nix or agenix to keep this file out of the Nix store.
      '';
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open <option>services.scrobblex.port</option> in the firewall.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.scrobblex = {
      description = "Scrobblex";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      environment =
        {
          PORT = toString cfg.port;
          LOG_LEVEL = cfg.logLevel;
        }
        // lib.optionalAttrs (cfg.plexUser != []) {
          PLEX_USER = lib.concatStringsSep "," cfg.plexUser;
        };

      serviceConfig = {
        Type = "simple";

        # DynamicUser means systemd allocates a transient user and owns the
        # StateDirectory.  The user name is derived from the service name so
        # it is stable across restarts (but not across rebuilds on impermanent
        # systems — see the note below).
        DynamicUser = true;

        # Creates /var/lib/scrobblex, chowned to the dynamic user.
        StateDirectory = "scrobblex";
        StateDirectoryMode = "0700";

        # All relative paths in the app (./data, ./static, ./views, ./favicon.ico)
        # are resolved against CWD.  Set CWD to the writable state directory.
        WorkingDirectory = stateDir;

        # Symlink read-only store assets into the state dir so Express can find
        # them.  The ./data directory is created automatically by node-localstorage
        # on first run.  We use -sfn so that upgrades pick up the new store paths.
        ExecStartPre = pkgs.writeShellScript "scrobblex-prestart" ''
          ln -sfn ${pkg}/lib/scrobblex/static    ${stateDir}/static
          ln -sfn ${pkg}/lib/scrobblex/views     ${stateDir}/views
          ln -sfn ${pkg}/lib/scrobblex/favicon.ico ${stateDir}/favicon.ico
        '';

        # Run node directly against the store source so we control the working
        # directory independently of the package wrapper.
        ExecStart = "${lib.getExe pkgs.nodejs} ${pkg}/lib/scrobblex/src/index.js";

        EnvironmentFile = lib.optional (cfg.environmentFile != null) cfg.environmentFile;

        Restart = "on-failure";
        RestartSec = "5s";

        # ── Hardening ──────────────────────────────────────────────────────
        NoNewPrivileges = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        # libuv uses AF_NETLINK (NETLINK_ROUTE) to query network interfaces
        # for Node.js os.networkInterfaces(); without it the process crashes.
        RestrictAddressFamilies = ["AF_INET" "AF_INET6" "AF_UNIX" "AF_NETLINK"];
        RestrictNamespaces = true;
        LockPersonality = true;
        # Node.js JIT requires the ability to map memory as writable+executable.
        MemoryDenyWriteExecute = false;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RemoveIPC = true;
        ReadWritePaths = [stateDir];
      };
    };

    networking.firewall.allowedTCPPorts = lib.optional cfg.openFirewall cfg.port;
  };
}
