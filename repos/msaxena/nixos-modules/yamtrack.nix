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

  # gunicorn is no longer part of this module's public option surface: it
  # binds to a fixed loopback-only address, and `services.yamtrack.host`/
  # `port` now describe the co-located proxy in front of it instead (see
  # those options' descriptions). This mirrors upstream's own Docker image,
  # which always runs gunicorn on 127.0.0.1:8001 behind an nginx that's the
  # only thing actually reachable -- see yamtrackCaddyfile below.
  gunicornPort = 8001;

  boolStr = b: if b then "true" else "false";

  isSqlite = cfg.database.host == null && !cfg.database.createLocally;

  # Keys the module computes for its own correctness/hardening and that
  # `environment` (a user-facing catch-all, see its description) must never
  # be able to shadow: HOME backs gunicorn's control socket path, and
  # SQLITE_PATH is what keeps the live database inside the persisted state
  # directory. Applied as the last override below, after cfg.environment.
  protectedEnv =
    { HOME = stateDir; }
    // lib.optionalAttrs isSqlite { SQLITE_PATH = "${stateDir}/db.sqlite3"; };

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
      VERSION = pkg.version;
      # Only gunicorn (the "yamtrack" service) reads this; harmless to also
      # set it in the manage/celery units' environment, which just ignore it.
      WEB_CONCURRENCY = toString cfg.workers;
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
    )
    // cfg.environment
    // protectedEnv;

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
    CapabilityBoundingSet = [ ];
    SystemCallArchitectures = "native";
    ProtectHostname = true;
    ProtectKernelLogs = true;
    ProtectClock = true;
    # Safe here specifically because the Python env is a fixed, closed
    # dependency set (no subprocess-spawning/psutil-style dependency) -- see
    # pkgs/yamtrack/default.nix's pythonEnv.
    ProtectProc = "invisible";
    UMask = "0077";
    SystemCallFilter = [ "@system-service" ];
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

  # Path static assets are served under, matching Django's own STATIC_URL
  # (which gets BASE_URL prefixed onto it -- see settings.py). `handle_path`
  # strips this whole prefix before handing off to file_server, same as
  # nginx's `alias` does for the equivalent `location` block.
  staticUrlPath = "${lib.optionalString (cfg.baseUrl != null) cfg.baseUrl}/static/*";

  # A small co-located Caddy instance standing in for upstream's bundled
  # nginx: serves collectstatic's output at /static/ and reverse-proxies
  # everything else to gunicorn, setting X-Real-IP along the way (required
  # by django-allauth's per-IP rate limiter -- see ALLAUTH_TRUSTED_CLIENT_IP_HEADER
  # in Yamtrack's settings.py; without it, every signup/login POST raises
  # PermissionDenied and 403s, even though gunicorn itself is perfectly
  # healthy). `admin off` disables Caddy's admin API, which this static
  # single-site config never needs.
  #
  # X-Forwarded-Proto is passed through from whatever this proxy itself
  # received, matching upstream nginx.conf's `$http_x_forwarded_proto`
  # verbatim-forward behavior -- deliberately, so that a consumer's own
  # TLS-terminating reverse proxy in front of this one (a normal setup; see
  # `services.yamtrack.urls`) still has its scheme reach gunicorn correctly.
  # As with nginx, this makes that header attacker-controlled input if this
  # proxy is instead exposed directly to untrusted clients (see openFirewall
  # below) with nothing in front of it to set/strip it first. X-Real-IP is
  # NOT forwarded this way -- it is always set from this proxy's own view of
  # the immediate peer address, so it can't be spoofed by an inbound header
  # regardless of exposure. (X-Forwarded-For needs no explicit handling
  # here: Caddy's reverse_proxy already sets it the same anti-spoofing way
  # by default, so overriding it would be redundant -- Caddy's own linter
  # flags exactly that.)
  yamtrackCaddyfile = pkgs.writeText "yamtrack-Caddyfile" ''
    {
        admin off
    }

    :${toString cfg.port} {
        # A Caddyfile site address's host part (e.g. "127.0.0.1" in
        # "http://127.0.0.1:8000") is a *Host-header matcher*, not a listen
        # filter -- Caddy still binds it wildcard regardless, and any
        # request whose Host header doesn't literally match gets an empty
        # default response instead of reaching the handlers below (e.g. a
        # client that reaches this proxy via "localhost" rather than
        # "127.0.0.1" would silently get nothing). `bind` is the actual
        # listen-address control, decoupled from Host-header matching --
        # this site intentionally matches any Host header, since gunicorn
        # behind it already validates Host via ALLOWED_HOSTS.
        bind ${cfg.host}

        header {
            X-Frame-Options "SAMEORIGIN"
            X-Content-Type-Options "nosniff"
            Referrer-Policy "no-referrer-when-downgrade"
        }

        handle_path ${staticUrlPath} {
            root * ${pkg}/share/yamtrack/src/staticfiles
            file_server
            header Cache-Control "public, max-age=2592000"
        }

        handle {
            reverse_proxy 127.0.0.1:${toString gunicornPort} {
                # {host} (unlike {http.request.hostport}) silently strips the
                # port, which breaks Django's CSRF Origin check: it compares
                # the browser's Origin header (scheme://host:port) against
                # one it builds from the forwarded Host header, and a
                # missing port makes those never match on any non-default
                # port -- every POST 403s ("Origin checking failed"), not
                # just cross-site ones.
                header_up Host {http.request.hostport}
                header_up X-Real-IP {remote_host}
                header_up X-Forwarded-Proto {http.request.header.X-Forwarded-Proto}
            }
        }
    }
  '';
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
        Address the module's co-located static-file/reverse-proxy front-end
        binds to (see {option}`services.yamtrack.port`) — mirroring upstream's
        own Docker image, gunicorn itself is no longer reachable directly; it
        always binds loopback-only on an internal, unconfigurable port.

        > **Warning**
        > Breaking change: before this module included its own proxy,
        > `host`/`port` were gunicorn's own bind address, and every consumer
        > had to put their own reverse proxy in front to get working static
        > assets and correct client-IP detection. Bumping to a module version
        > with this option's new meaning changes what is actually listening
        > on `host`:`port` — re-check any firewall/proxy config that assumed
        > it was gunicorn.
      '';
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8000;
      description = ''
        TCP port the module's co-located proxy listens on (see
        {option}`services.yamtrack.host` for the breaking-change note on what
        this used to mean). Matches upstream's own nginx/gunicorn split
        (public :8000, internal gunicorn on 127.0.0.1:8001).
      '';
    };

    workers = lib.mkOption {
      type = lib.types.ints.positive;
      default = 1;
      description = "Number of gunicorn worker processes (WEB_CONCURRENCY).";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Open {option}`services.yamtrack.port` in the firewall. That port's
        proxy passes through whatever `X-Forwarded-Proto` header it itself
        received (matching upstream's nginx.conf) — only enable this if
        clients cannot reach the proxy directly without going through
        another reverse proxy that sets or strips that header first,
        otherwise it is attacker-controlled input.
      '';
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

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = {
        VERSION = "custom-build-label";
      };
      description = ''
        Extra non-secret environment variables passed to the Yamtrack
        service verbatim, for anything upstream reads via python-decouple
        that isn't already covered by a dedicated option above — see
        Yamtrack's `src/config/settings.py` for the full list of `config()`
        calls. Values set here take precedence over the dedicated options,
        with two exceptions this module always pins regardless: `HOME`
        (backs gunicorn's control socket path) and `SQLITE_PATH` (keeps the
        database inside the persisted state directory) — setting either here
        is a no-op.
      '';
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
      environment = commonEnv;
      serviceConfig = baseServiceConfig // {
        Type = "simple";
        ExecStart = "${pkg}/bin/yamtrack-gunicorn --bind 127.0.0.1:${toString gunicornPort}";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };

    systemd.services.yamtrack-proxy = {
      description = "Yamtrack static-file/reverse-proxy front-end (co-located Caddy, mirrors upstream's bundled nginx)";
      after = [
        "network.target"
        "yamtrack.service"
      ];
      # Soft dependency only: this proxy can stay up (serving /static/ and
      # passing through 502s) across a gunicorn restart, so it shouldn't be
      # torn down whenever yamtrack.service is -- unlike yamtrack-worker's
      # `requires` on yamtrack-migrate, which genuinely cannot function
      # before migrations have run.
      wants = [ "yamtrack.service" ];
      wantedBy = [ "multi-user.target" ];

      # Caddy always tries to persist an autosave of its last-loaded config
      # to $XDG_DATA_HOME/caddy on startup, even with the admin API disabled
      # -- give it a private, writable scratch space rather than letting it
      # fall back to a homeless system user's unwritable $HOME.
      environment = {
        HOME = "/run/yamtrack-proxy";
        XDG_DATA_HOME = "/run/yamtrack-proxy";
        XDG_CONFIG_HOME = "/run/yamtrack-proxy";
        XDG_CACHE_HOME = "/run/yamtrack-proxy";
      };

      serviceConfig = {
        DynamicUser = true;
        RuntimeDirectory = "yamtrack-proxy";
        ExecStart = "${lib.getExe pkgs.caddy} run --config ${yamtrackCaddyfile} --adapter caddyfile";
        Restart = "on-failure";
        RestartSec = "5s";

        # Lets `services.yamtrack.port` be a privileged port (e.g. 80/443)
        # without running any part of this as root.
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];

        # A stateless local proxy has a much smaller attack surface than the
        # Django app (baseServiceConfig above) -- same hardening density
        # where it applies, minus the state-directory/user plumbing this
        # unit doesn't need.
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
        ];
        RestrictNamespaces = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RemoveIPC = true;
        SystemCallArchitectures = "native";
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectClock = true;
        ProtectProc = "invisible";
        UMask = "0077";
        SystemCallFilter = [ "@system-service" ];
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
