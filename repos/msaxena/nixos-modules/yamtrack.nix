{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.yamtrack;
  pkg = cfg.package;

  # Everything Yamtrack needs to import settings.py successfully resolves
  # against the read-only package output (see pkgs/yamtrack for the patches
  # that make that possible). The only writable state is the sqlite file
  # (SQLITE_PATH, patched in) and, when using a local Postgres, its own data
  # directory — nothing else needs persisting. Redis holds only cache/broker
  # data; django-celery-beat stores its schedule in the database, not Redis.
  stateDir = "/var/lib/yamtrack";

  boolStr = b: if b then "true" else "false";

  # Settings that are inherently credential-shaped (API keys, OAuth client
  # secrets, the Django SECRET_KEY, a remote DB_PASSWORD, ...) are
  # deliberately *not* exposed as plain Nix string options: `services.*`
  # values land verbatim in the systemd unit file under /nix/store, which is
  # world-readable. Put them in `environmentFiles` instead (see its
  # description for the full list of supported keys) — e.g. a file produced
  # by sops-nix.
  commonEnv =
    {
      # Give gunicorn a writable $HOME for its control socket (it otherwise
      # tries ~/.gunicorn, which resolves under the read-only ProtectHome=
      # jail for a homeless system user).
      HOME = stateDir;
      TZ = cfg.timeZone;
      DEBUG = boolStr cfg.debug;
      ADMIN_ENABLED = boolStr cfg.adminEnabled;
      REGISTRATION = boolStr cfg.registrationEnabled;
      TRACK_TIME = boolStr cfg.trackTime;
      ALLOWED_HOSTS = lib.concatStringsSep "," cfg.allowedHosts;
      CSRF = lib.concatStringsSep "," cfg.csrfTrustedOrigins;
      URLS = lib.concatStringsSep "," cfg.urls;
      SESSION_COOKIE_AGE = toString cfg.sessionCookieAge;
      DAILY_DIGEST_HOUR = toString cfg.dailyDigestHour;
      USER_MESSAGE_RETENTION_DAYS = toString cfg.userMessageRetentionDays;
      HEALTHCHECK_CELERY_PING_TIMEOUT = toString cfg.healthcheckCeleryPingTimeout;
      REDIS_URL = cfg.redis.url;
      CELERY_REDIS_URL = if cfg.redis.celeryUrl != null then cfg.redis.celeryUrl else cfg.redis.url;
      SOCIAL_PROVIDERS = lib.concatStringsSep "," cfg.socialProviders;
      SOCIALACCOUNT_ONLY = boolStr cfg.socialAccountOnly;
      REDIRECT_LOGIN_TO_SSO = boolStr cfg.redirectLoginToSso;
      TMDB_NSFW = boolStr cfg.providers.tmdb.nsfw;
      TMDB_LANG = cfg.providers.tmdb.language;
      MAL_NSFW = boolStr cfg.providers.mal.nsfw;
      MU_NSFW = boolStr cfg.providers.mangaUpdates.nsfw;
      IGDB_NSFW = boolStr cfg.providers.igdb.nsfw;
    }
    // lib.optionalAttrs (cfg.baseUrl != null) { BASE_URL = cfg.baseUrl; }
    // lib.optionalAttrs (cfg.redis.prefix != null) { REDIS_PREFIX = cfg.redis.prefix; }
    // lib.optionalAttrs (cfg.autoLoginUsername != null) {
      YAMTRACK_AUTO_LOGIN_USERNAME = cfg.autoLoginUsername;
    }
    // lib.optionalAttrs (cfg.accountDefaultHttpProtocol != null) {
      ACCOUNT_DEFAULT_HTTP_PROTOCOL = cfg.accountDefaultHttpProtocol;
    }
    // lib.optionalAttrs (cfg.accountLogoutRedirectUrl != null) {
      ACCOUNT_LOGOUT_REDIRECT_URL = cfg.accountLogoutRedirectUrl;
    }
    // lib.optionalAttrs (cfg.requestsCaBundle != null) {
      REQUESTS_CA_BUNDLE = cfg.requestsCaBundle;
    }
    // (
      if cfg.database.createLocally then
        {
          DB_HOST = "/run/postgresql";
          DB_PORT = toString cfg.database.port;
          DB_NAME = cfg.database.name;
          DB_USER = cfg.database.user;
          # Peer auth over the local Unix socket ignores the password, but
          # Yamtrack requires DB_PASSWORD to be set to *something* once
          # DB_HOST is set.
          DB_PASSWORD = "";
        }
      else if cfg.database.host != null then
        {
          DB_HOST = cfg.database.host;
          DB_PORT = toString cfg.database.port;
          DB_NAME = cfg.database.name;
          DB_USER = cfg.database.user;
          # DB_PASSWORD is required here too — set it via environmentFiles.
        }
        // lib.optionalAttrs (cfg.database.sslMode != null) { DB_SSL_MODE = cfg.database.sslMode; }
        // lib.optionalAttrs (cfg.database.sslCertMode != null) {
          DB_SSL_CERT_MODE = cfg.database.sslCertMode;
        }
      else
        {
          SQLITE_PATH = "${stateDir}/db.sqlite3";
        }
    );

  hardening = {
    NoNewPrivileges = true;
    PrivateTmp = true;
    PrivateDevices = true;
    ProtectSystem = "strict";
    ProtectHome = true;
    ProtectKernelTunables = true;
    ProtectKernelModules = true;
    ProtectControlGroups = true;
    RestrictAddressFamilies = [
      "AF_INET"
      "AF_INET6"
      "AF_UNIX"
    ];
    RestrictNamespaces = true;
    LockPersonality = true;
    MemoryDenyWriteExecute = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    RemoveIPC = true;
  };

  baseServiceConfig = {
    User = "yamtrack";
    Group = "yamtrack";
    StateDirectory = "yamtrack";
    StateDirectoryMode = "0750";
    WorkingDirectory = stateDir;
    EnvironmentFile = cfg.environmentFiles;
    ReadWritePaths = [ stateDir ];
  }
  // hardening;

  dbUnitDeps = lib.optional cfg.database.createLocally "postgresql.service";
in
{
  options.services.yamtrack = {
    enable = lib.mkEnableOption "Yamtrack self-hosted media tracker";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.nur.repos.msaxena.yamtrack;
      defaultText = lib.literalExpression "pkgs.nur.repos.msaxena.yamtrack";
      description = "The Yamtrack package to use.";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = ''
        Address gunicorn binds to. Yamtrack does not ship a bundled reverse
        proxy (the upstream Docker image's nginx/static-file layer is not
        part of this package) — put a proxy such as
        {option}`services.nginx.virtualHosts` in front of it and serve
        `${"$"}{package}/share/yamtrack/src/staticfiles` at `/static/`.
      '';
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8001;
      description = "TCP port gunicorn listens on.";
    };

    workers = lib.mkOption {
      type = lib.types.ints.positive;
      default = 1;
      description = "Number of gunicorn worker processes (WEB_CONCURRENCY).";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open {option}`services.yamtrack.port` in the firewall.";
    };

    timeZone = lib.mkOption {
      type = lib.types.str;
      default = "UTC";
      example = "America/New_York";
      description = "Timezone Yamtrack uses for scheduling (TZ).";
    };

    debug = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Django debug mode. Never enable this on a public instance.";
    };

    adminEnabled = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the Django admin interface at `/admin/`.";
    };

    registrationEnabled = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Allow new users to register an account.";
    };

    trackTime = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Yamtrack's time-tracking feature.";
    };

    baseUrl = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "/yamtrack";
      description = "Subpath Yamtrack is served from, if not at the domain root (BASE_URL).";
    };

    allowedHosts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "*" ];
      example = [ "yamtrack.example.com" ];
      description = "Host/domain names this Django site is allowed to serve (ALLOWED_HOSTS).";
    };

    urls = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "https://yamtrack.example.com" ];
      description = ''
        Public origins Yamtrack is reachable at, including scheme
        (URLS). Shortcut that populates both ALLOWED_HOSTS and
        CSRF_TRUSTED_ORIGINS; required behind a reverse proxy to avoid 403s
        on login/OAuth callbacks.
      '';
    };

    csrfTrustedOrigins = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "https://yamtrack.example.com" ];
      description = "Additional trusted origins for unsafe (POST) requests (CSRF).";
    };

    sessionCookieAge = lib.mkOption {
      type = lib.types.ints.positive;
      default = 60 * 60 * 24 * 14;
      description = "Session cookie lifetime in seconds (SESSION_COOKIE_AGE).";
    };

    autoLoginUsername = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Automatically log every visitor in as this username, bypassing
        authentication entirely (YAMTRACK_AUTO_LOGIN_USERNAME). Only ever
        use this if {option}`services.yamtrack.host` is bound to a network
        no untrusted party can reach.
      '';
    };

    dailyDigestHour = lib.mkOption {
      type = lib.types.ints.between 0 23;
      default = 8;
      description = "Local hour at which the daily digest notification is sent (DAILY_DIGEST_HOUR).";
    };

    userMessageRetentionDays = lib.mkOption {
      type = lib.types.ints.positive;
      default = 30;
      description = "Days to keep read in-app user messages before cleanup (USER_MESSAGE_RETENTION_DAYS).";
    };

    healthcheckCeleryPingTimeout = lib.mkOption {
      type = lib.types.ints.positive;
      default = 1;
      description = "Timeout in seconds for the /health/ endpoint's Celery ping check.";
    };

    requestsCaBundle = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Custom CA bundle for outgoing HTTPS requests to metadata providers (REQUESTS_CA_BUNDLE).";
    };

    socialProviders = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "allauth.socialaccount.providers.openid_connect" ];
      description = ''
        django-allauth provider app paths to enable (SOCIAL_PROVIDERS).
        Provider client IDs/secrets go in {option}`services.yamtrack.environmentFiles`
        as SOCIALACCOUNT_PROVIDERS (JSON) — see django-allauth's docs for its shape.
      '';
    };

    socialAccountOnly = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Disable local username/password login, allowing only social/SSO login (SOCIALACCOUNT_ONLY).";
    };

    redirectLoginToSso = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Redirect the login page straight to the configured SSO provider (REDIRECT_LOGIN_TO_SSO).";
    };

    accountDefaultHttpProtocol = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ "http" "https" ]);
      default = null;
      description = ''
        Protocol used to build absolute URLs for OAuth callbacks
        (ACCOUNT_DEFAULT_HTTP_PROTOCOL). Usually auto-detected from
        {option}`services.yamtrack.urls`; only set this to override.
      '';
    };

    accountLogoutRedirectUrl = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Where to send users after logout (ACCOUNT_LOGOUT_REDIRECT_URL).";
    };

    redis = {
      url = lib.mkOption {
        type = lib.types.str;
        default = "redis://127.0.0.1:6379";
        description = ''
          Redis connection URL, used for Django's cache and as the Celery
          broker (REDIS_URL). This module does not provision Redis; point it
          at your own instance (e.g. `services.redis.servers.<name>`). Redis
          only holds cache/broker data here — nothing needs to survive a
          restart, so it is not a concern for impermanence.
        '';
      };

      celeryUrl = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Redis URL for Celery if different from `redis.url` (CELERY_REDIS_URL).";
      };

      prefix = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "yamtrack";
        description = "Key prefix for isolating this instance's keys on a shared Redis (REDIS_PREFIX).";
      };
    };

    database = {
      createLocally = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Create a local PostgreSQL database and role via
          {option}`services.postgresql`, authenticated over the Unix socket
          with peer auth (no password involved at all). Mutually exclusive
          in effect with {option}`services.yamtrack.database.host` — this
          takes precedence when enabled.
        '';
      };

      host = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = ''
          PostgreSQL server hostname (DB_HOST). Leave null to use a local
          sqlite database file under {file}`/var/lib/yamtrack` instead,
          matching Yamtrack's own default. Ignored when
          {option}`services.yamtrack.database.createLocally` is set.
        '';
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 5432;
        description = "PostgreSQL server port (DB_PORT).";
      };

      name = lib.mkOption {
        type = lib.types.str;
        default = "yamtrack";
        description = "PostgreSQL database name (DB_NAME).";
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = "yamtrack";
        description = "PostgreSQL role name (DB_USER).";
      };

      sslMode = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.enum [
            "disable"
            "allow"
            "prefer"
            "require"
            "verify-ca"
            "verify-full"
          ]
        );
        default = null;
        description = "PostgreSQL SSL negotiation mode (DB_SSL_MODE). Only used for a remote database.";
      };

      sslCertMode = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "PostgreSQL client certificate requirement (DB_SSL_CERT_MODE).";
      };
    };

    providers = {
      tmdb = {
        nsfw = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Include adult content in TMDB movie/TV search results (TMDB_NSFW).";
        };
        language = lib.mkOption {
          type = lib.types.str;
          default = "en";
          description = "TMDB metadata language, an ISO 639-1 code (TMDB_LANG).";
        };
      };
      mal = {
        nsfw = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Include adult content in MyAnimeList anime/manga search results (MAL_NSFW).";
        };
      };
      mangaUpdates = {
        nsfw = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Include adult content in MangaUpdates manga search results (MU_NSFW).";
        };
      };
      igdb = {
        nsfw = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Include adult content in IGDB game search results (IGDB_NSFW).";
        };
      };
    };

    celery = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Run the Celery worker/beat service. This drives release
          notifications, the daily digest, calendar refreshes and the
          /health/ endpoint's Celery check — there is little reason to turn
          it off.
        '';
      };
    };

    environmentFiles = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [ ];
      example = lib.literalExpression ''[ config.sops.secrets."yamtrack-env".path ]'';
      description = ''
        Files of `KEY=value` lines loaded into the service environment
        (systemd `EnvironmentFile=`), for anything credential-shaped. Works
        directly with sops-nix: point this at a templated secret or a
        `sops.secrets."name".path`. Supported keys, all optional unless
        noted:

          SECRET=                 # Django SECRET_KEY (required in practice)
          DB_PASSWORD=            # only when database.host is set (remote Postgres)
          TMDB_API=
          TVDB_API=
          MAL_API=
          IGDB_ID=
          IGDB_SECRET=
          BGG_API_TOKEN=
          STEAM_API_KEY=
          HARDCOVER_API=          # must include the "Bearer " prefix
          COMICVINE_API=
          TRAKT_API=
          TRAKT_API_SECRET=
          ANILIST_ID=
          ANILIST_SECRET=
          SIMKL_ID=
          SIMKL_SECRET=
          SOCIALACCOUNT_PROVIDERS=   # JSON, see django-allauth's docs

        All of these have working shared defaults baked into Yamtrack except
        SECRET, so none are strictly required to get a working instance —
        set only the ones you want to override.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.yamtrack = {
      isSystemUser = true;
      group = "yamtrack";
    };
    users.groups.yamtrack = { };

    services.postgresql = lib.mkIf cfg.database.createLocally {
      enable = true;
      ensureDatabases = [ cfg.database.name ];
      ensureUsers = [
        {
          name = cfg.database.user;
          ensureDBOwnership = true;
        }
      ];
    };

    systemd.services.yamtrack-migrate = {
      description = "Yamtrack database migrations";
      after = [ "network.target" ] ++ dbUnitDeps;
      requires = dbUnitDeps;
      environment = commonEnv;
      serviceConfig = baseServiceConfig // {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkg}/bin/yamtrack-manage migrate --noinput";
      };
    };

    systemd.services.yamtrack = {
      description = "Yamtrack web server";
      after = [
        "network.target"
        "yamtrack-migrate.service"
      ] ++ dbUnitDeps;
      requires = [ "yamtrack-migrate.service" ] ++ dbUnitDeps;
      wantedBy = [ "multi-user.target" ];
      environment = commonEnv // {
        WEB_CONCURRENCY = toString cfg.workers;
      };
      serviceConfig = baseServiceConfig // {
        Type = "simple";
        ExecStart = "${pkg}/bin/yamtrack-gunicorn --bind ${cfg.host}:${toString cfg.port}";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };

    systemd.services.yamtrack-worker = lib.mkIf cfg.celery.enable {
      description = "Yamtrack Celery worker and beat scheduler";
      after = [
        "network.target"
        "yamtrack-migrate.service"
      ] ++ dbUnitDeps;
      requires = [ "yamtrack-migrate.service" ] ++ dbUnitDeps;
      wantedBy = [ "multi-user.target" ];
      environment = commonEnv;
      serviceConfig = baseServiceConfig // {
        Type = "simple";
        ExecStart = "${pkg}/bin/yamtrack-celery worker --beat --loglevel INFO --without-mingle --without-gossip";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };

    networking.firewall.allowedTCPPorts = lib.optional cfg.openFirewall cfg.port;
  };
}
