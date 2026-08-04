{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.trek;
  pkg = cfg.package;
  isDefaultDataDir = cfg.dataDir == "/var/lib/trek";

  # Subdirectories the server expects to exist under "./data" and
  # "./uploads" (matching upstream's Docker entrypoint), relative to
  # dataDir.
  stateSubdirs = [
    "data"
    "data/logs"
    "uploads"
    "uploads/files"
    "uploads/covers"
    "uploads/avatars"
    "uploads/photos"
  ];

  optionalEnv = name: value: lib.optionalAttrs (value != null) {${name} = value;};
in {
  options.services.trek = {
    enable = lib.mkEnableOption "TREK, a self-hosted collaborative travel planner";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.nur.repos.msaxena.trek;
      defaultText = lib.literalExpression "pkgs.nur.repos.msaxena.trek";
      description = "The TREK package to use.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 3000;
      description = "TCP port TREK listens on.";
    };

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      example = "0.0.0.0";
      description = ''
        Address TREK binds to. Upstream only expects this to be set outside
        of Docker (where the container itself provides network isolation),
        which applies here.
      '';
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/trek";
      description = ''
        Directory holding TREK's SQLite database and uploaded files
        ("data" and "uploads" subdirectories are created underneath it).

        Left at the default, this directory is fully managed (created,
        permissioned and owned) by systemd via `StateDirectory=`, which is
        also what makes it trivially impermanence-compatible: just add
        `/var/lib/trek` to your `environment.persistence.<name>.directories`
        (or `.../users.<user>.directories` if run as a non-system user) and
        nothing else needs to change here, since the persistent bind mount
        is transparently in place before this service ever starts.

        If you point this elsewhere, systemd's automatic directory
        management no longer applies: you are responsible for making sure
        `''${dataDir}/data` and `''${dataDir}/uploads` (with their
        `logs`/`files`/`covers`/`avatars`/`photos` subdirectories) exist and
        are writable by the service before it starts, e.g. via your own
        `systemd.tmpfiles.rules`.
      '';
    };

    timezone = lib.mkOption {
      type = lib.types.str;
      default = "UTC";
      example = "Europe/Berlin";
      description = "Timezone for logs, reminders and scheduled tasks.";
    };

    logLevel = lib.mkOption {
      type = lib.types.enum ["info" "debug"];
      default = "info";
      description = ''
        `info` logs concise user actions; `debug` adds verbose admin-level
        details.
      '';
    };

    allowedOrigins = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      example = ["https://trek.example.com"];
      description = ''
        Origins allowed for CORS and used in email links. Required in
        practice once TREK is reachable from anywhere but localhost.
      '';
    };

    appUrl = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "https://trek.example.com";
      description = ''
        Base URL of this instance. Required when OIDC is enabled, and must
        match the redirect URI registered with the identity provider.
      '';
    };

    forceHttps = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Enable HTTPS redirect, HSTS and CSP upgrade-insecure-requests. Only
        enable this behind a TLS-terminating reverse proxy. Note this does
        *not* gate secure cookies on its own here — see
        {option}`services.trek.cookieSecure`.
      '';
    };

    hstsIncludeSubdomains = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Add `includeSubDomains` to the HSTS header. TREK sends HSTS whenever
        `NODE_ENV=production` (which this module always sets) or
        `forceHttps` is enabled — in practice that means always, regardless
        of `forceHttps`. This is normally harmless (browsers ignore HSTS
        headers received over a plain HTTP connection), but leave it
        disabled if you run other services on sibling subdomains that are
        themselves reachable over plain HTTP through a shared TLS-terminating
        proxy.
      '';
    };

    cookieSecure = lib.mkOption {
      type = lib.types.nullOr lib.types.bool;
      default = null;
      description = ''
        Whether the session cookie requires HTTPS. Left unset, this tracks
        {option}`services.trek.forceHttps` (secure when `forceHttps` is
        enabled). Upstream itself would otherwise auto-derive this from
        `NODE_ENV=production` -- which this module always sets, making
        cookies secure unconditionally -- so this module pins `COOKIE_SECURE`
        explicitly instead of leaving it to that auto-derivation. Set this to
        `false` to force cookies over plain HTTP even with `forceHttps`
        enabled (not recommended); set it to `true` to force secure cookies
        while `forceHttps` is off (e.g. a TLS-terminating proxy where you
        don't want TREK's own HTTPS redirect/HSTS behavior).
      '';
    };

    trustProxy = lib.mkOption {
      type = lib.types.nullOr lib.types.ints.unsigned;
      default = null;
      example = 1;
      description = ''
        Number of trusted reverse-proxy hops. Needed for `forceHttps` to
        work correctly behind a reverse proxy.
      '';
    };

    allowInternalNetwork = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Allow outbound requests to private/RFC1918 addresses, e.g. for a
        LAN-hosted Immich instance. Loopback and link-local addresses are
        always blocked regardless of this setting.
      '';
    };

    defaultLanguage = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum ["de" "en" "es" "fr" "hu" "nl" "br" "cs" "pl" "ru" "zh" "zh-TW" "it" "ar"]);
      default = null;
      description = ''
        Default language on the login page for users with no saved
        preference. Browser/OS language is detected automatically first;
        this is only the fallback. Left unset, TREK defaults to `en`.
      '';
    };

    sessionDuration = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "30d";
      description = ''
        How long users stay logged in (JWT expiry + cookie maxAge). Accepts
        `1h`, `12h`, `7d`, `30d`, `90d`. Left unset, TREK defaults to `24h`.
      '';
    };

    sessionDurationRemember = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "90d";
      description = ''
        Session length when "Remember me" is ticked at login. Same format as
        `sessionDuration`. Left unset, TREK defaults to `30d`.
      '';
    };

    demoMode = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Demo mode. Resets data hourly; do not enable in a real deployment.";
    };

    backupUploadLimitMb = lib.mkOption {
      type = lib.types.nullOr lib.types.ints.positive;
      default = null;
      example = 500;
      description = ''
        Max size, in MB, of a backup archive you can upload when restoring.
        Left unset, TREK defaults to 500. If TREK sits behind a reverse
        proxy, raise its upload limit too (e.g. nginx's `client_max_body_size`).
      '';
    };

    mcp = {
      rateLimit = lib.mkOption {
        type = lib.types.nullOr lib.types.ints.positive;
        default = null;
        description = "Max MCP API requests per user per minute. Left unset, TREK defaults to 300.";
      };

      maxSessionsPerUser = lib.mkOption {
        type = lib.types.nullOr lib.types.ints.positive;
        default = null;
        description = "Max concurrent MCP sessions per user. Left unset, TREK defaults to 20.";
      };
    };

    overpass = {
      urls = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = ''
          Custom Overpass endpoint(s) for the map POI "explore" search. When
          set, this replaces the bundled public mirrors -- point it at an
          internal/self-hosted Overpass instance when the public ones are
          unreachable from your network.
        '';
      };

      timeoutMs = lib.mkOption {
        type = lib.types.nullOr lib.types.ints.positive;
        default = null;
        description = "Per-endpoint timeout for Overpass POI requests, in milliseconds. Left unset, TREK defaults to 12000.";
      };
    };

    oidc = {
      issuer = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "https://auth.example.com";
        description = "OpenID Connect provider URL.";
      };

      clientId = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = ''
          OpenID Connect client ID. The client secret is deliberately not a
          plain option here -- put `OIDC_CLIENT_SECRET=...` in
          `environmentFiles` instead.
        '';
      };

      displayName = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "SSO";
        description = "Label shown on the SSO login button.";
      };

      only = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Disable local password auth entirely (SSO only). Equivalent to
          setting password_login=false and password_registration=false in
          Admin > Settings.
        '';
      };

      adminClaim = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "groups";
        description = "OIDC claim used to identify admin users.";
      };

      adminValue = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Value of the OIDC claim that grants admin role.";
      };

      discoveryUrl = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = ''
          Override the auto-constructed OIDC discovery endpoint. Useful for
          providers (e.g. Authentik) that expose it at a non-standard path.
        '';
      };

      scope = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "openid email profile";
        description = "Fully overrides the default OIDC scope list.";
      };
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      example = {
        SMTP_HOST = "smtp.example.com";
        SMTP_PORT = "587";
        WEBAUTHN_RP_ID = "trek.example.com";
      };
      description = ''
        Extra non-secret environment variables passed to the TREK service
        verbatim, for tunables not otherwise covered by a dedicated option
        above (SMTP settings, WebAuthn origins, the plugin system, etc. --
        see upstream's `.env.example` and README for the full list). Values
        set here take precedence over the dedicated options.
      '';
    };

    environmentFiles = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [];
      example = lib.literalExpression ''[ config.sops.secrets.trek-env.path ]'';
      description = ''
        Files of secret environment variables (`KEY=value` per line),
        loaded by systemd before the service starts and merged in order
        (later files win on conflicts). This is where `ENCRYPTION_KEY`,
        first-boot `ADMIN_EMAIL`/`ADMIN_PASSWORD`, `OIDC_CLIENT_SECRET`,
        SMTP credentials and `UNSPLASH_ACCESS_KEY` belong.

        Works directly with sops-nix: pass
        `[ config.sops.secrets.trek-env.path ]`, or one path per secret if
        you'd rather keep them in separate sops files.
      '';
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open <option>services.trek.port</option> in the firewall.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.trek = {
      isSystemUser = true;
      group = "trek";
    };
    users.groups.trek = {};

    systemd.services.trek = {
      description = "TREK travel planner";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      environment =
        {
          NODE_ENV = "production";
          PORT = toString cfg.port;
          HOST = cfg.listenAddress;
          TZ = cfg.timezone;
          LOG_LEVEL = cfg.logLevel;
          FORCE_HTTPS = lib.boolToString cfg.forceHttps;
          HSTS_INCLUDE_SUBDOMAINS = lib.boolToString cfg.hstsIncludeSubdomains;
          ALLOW_INTERNAL_NETWORK = lib.boolToString cfg.allowInternalNetwork;
          DEMO_MODE = lib.boolToString cfg.demoMode;
        }
        // optionalEnv "ALLOWED_ORIGINS" (
          if cfg.allowedOrigins == []
          then null
          else lib.concatStringsSep "," cfg.allowedOrigins
        )
        // optionalEnv "APP_URL" cfg.appUrl
        // optionalEnv "TRUST_PROXY" (
          if cfg.trustProxy == null
          then null
          else toString cfg.trustProxy
        )
        // {
          # Always set explicitly rather than leaving COOKIE_SECURE unset:
          # upstream's own auto-derivation is "secure when NODE_ENV=production
          # OR FORCE_HTTPS=true", and this module always sets
          # NODE_ENV=production above, so leaving it to auto-derive would
          # make cookies secure unconditionally -- silently breaking login
          # over plain HTTP for anyone running with forceHttps = false.
          COOKIE_SECURE = lib.boolToString (
            if cfg.cookieSecure != null then cfg.cookieSecure else cfg.forceHttps
          );
        }
        // optionalEnv "DEFAULT_LANGUAGE" cfg.defaultLanguage
        // optionalEnv "SESSION_DURATION" cfg.sessionDuration
        // optionalEnv "SESSION_DURATION_REMEMBER" cfg.sessionDurationRemember
        // optionalEnv "BACKUP_UPLOAD_LIMIT_MB" (
          if cfg.backupUploadLimitMb == null
          then null
          else toString cfg.backupUploadLimitMb
        )
        // optionalEnv "MCP_RATE_LIMIT" (
          if cfg.mcp.rateLimit == null
          then null
          else toString cfg.mcp.rateLimit
        )
        // optionalEnv "MCP_MAX_SESSION_PER_USER" (
          if cfg.mcp.maxSessionsPerUser == null
          then null
          else toString cfg.mcp.maxSessionsPerUser
        )
        // optionalEnv "OVERPASS_URL" (
          if cfg.overpass.urls == []
          then null
          else lib.concatStringsSep "," cfg.overpass.urls
        )
        // optionalEnv "OVERPASS_TIMEOUT_MS" (
          if cfg.overpass.timeoutMs == null
          then null
          else toString cfg.overpass.timeoutMs
        )
        // optionalEnv "OIDC_ISSUER" cfg.oidc.issuer
        // optionalEnv "OIDC_CLIENT_ID" cfg.oidc.clientId
        // optionalEnv "OIDC_DISPLAY_NAME" cfg.oidc.displayName
        // lib.optionalAttrs cfg.oidc.only {OIDC_ONLY = "true";}
        // optionalEnv "OIDC_ADMIN_CLAIM" cfg.oidc.adminClaim
        // optionalEnv "OIDC_ADMIN_VALUE" cfg.oidc.adminValue
        // optionalEnv "OIDC_DISCOVERY_URL" cfg.oidc.discoveryUrl
        // optionalEnv "OIDC_SCOPE" cfg.oidc.scope
        // cfg.environment;

      serviceConfig =
        {
          Type = "simple";

          # A static user, not DynamicUser: with DynamicUser, systemd's
          # StateDirectory implementation stores the real files under
          # /var/lib/private/trek/... and presents them at /var/lib/trek/...
          # through an idmapped mount scoped to *that* mount point. Our own
          # BindPaths= below bind-mounts the same source onto a second target
          # (inside the store) -- a plain rbind, which does not carry that
          # idmap translation along -- so the app would see the untranslated
          # underlying ownership through the bind-mounted view and fail with
          # EACCES even though the "native" /var/lib/trek/data path is
          # perfectly writable. A static user's StateDirectory is chowned
          # for real (no idmap indirection), so every path referencing it,
          # bind-mounted or not, agrees on the same plain ownership.
          User = "trek";
          Group = "trek";

          # The server resolves node_modules and tsconfig.json (for
          # tsconfig-paths) relative to the working directory, so it must
          # run from within the package's server directory; "./data" and
          # "./uploads" are bind-mounted in from dataDir below.
          WorkingDirectory = "${pkg}/lib/trek/server";
          ExecStart = "${lib.getExe pkgs.nodejs} --require tsconfig-paths/register ${pkg}/lib/trek/server/dist/index.js";

          BindPaths = [
            "${cfg.dataDir}/data:${pkg}/lib/trek/server/data"
            "${cfg.dataDir}/uploads:${pkg}/lib/trek/server/uploads"
          ];

          EnvironmentFile = cfg.environmentFiles;

          Restart = "on-failure";
          RestartSec = "5s";

          # ── Hardening ──────────────────────────────────────────────────
          NoNewPrivileges = true;
          PrivateTmp = true;
          PrivateDevices = true;
          ProtectSystem = "strict";
          ProtectHome = true;
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
          ProtectControlGroups = true;
          RestrictAddressFamilies = ["AF_INET" "AF_INET6" "AF_UNIX" "AF_NETLINK"];
          RestrictNamespaces = true;
          LockPersonality = true;
          # Node.js JIT requires the ability to map memory as writable+executable.
          MemoryDenyWriteExecute = false;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          RemoveIPC = true;
          ReadWritePaths = [cfg.dataDir];
        }
        // lib.optionalAttrs isDefaultDataDir {
          StateDirectory = map (d: "trek/${d}") stateSubdirs;
          StateDirectoryMode = "0700";
        };
    };

    networking.firewall.allowedTCPPorts = lib.optional cfg.openFirewall cfg.port;
  };
}
