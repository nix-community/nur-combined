{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.reader-server-rs;
  mylib = import ../../lib { inherit pkgs; };
  myCallPackage = pkgs.newScope (pkgs // mylib);
  defaultPackage = myCallPackage ../../pkgs/reader-server-rs { };
  settingsFormat = pkgs.formats.json { };
  # the app reads ./config.json from its working directory
  stateDir = "/var/lib/reader-server-rs";

  # Declared options default to null on purpose: null leaves are stripped
  # before writing config.json, so unset options fall back to the app's own
  # defaults (container-level serde(default) in config.rs) — the app stays
  # the single source of truth. Declared options exist for type checking
  # and docs only. (Options without any default would break eval: the
  # freeform merge forces every declared option.)
  # 剔除 null 字段；清空后的空段（如 "log": {}）也一并移除
  stripNulls =
    v:
    if v == null then
      null
    else if lib.isAttrs v && !lib.isDerivation v then
      let
        cleaned = lib.filterAttrs (_: v': v' != null) (lib.mapAttrs (_: stripNulls) v);
      in
      if cleaned == { } then null else cleaned
    else
      v;

  # 顶层全空时 stripNulls 返回 null，写出来会是 JSON null 而非 {}，这里兜底
  configFile =
    let
      stripped = stripNulls cfg.settings;
    in
    settingsFormat.generate "reader-server-rs.json" (if stripped == null then { } else stripped);

  # unset leaves are null (declared default); the app default is a relative
  # path inside the state directory: already writable via StateDirectory
  absPath = p: if lib.hasPrefix "/" (toString p) then toString p else "${stateDir}/${toString p}";

  bookDir = lib.mapNullable absPath cfg.settings.storage.book_dir;
  logDir = lib.mapNullable absPath cfg.settings.log.dir;

  # "sqlite:///abs/path.db" -> "/abs/path.db"; "sqlite:reader.db" -> stateDir/reader.db;
  # unset or non-sqlite (e.g. postgres) -> null
  dbFile =
    let
      url = cfg.settings.db.url;
      has = p: url != null && lib.hasPrefix p url;
    in
    if has "sqlite:///" then
      lib.removePrefix "sqlite://" url
    else if has "sqlite:" then
      absPath (lib.removePrefix "sqlite:" url)
    else
      null;

  # null (unset) counts as missing, same as ""
  jwtSecret = cfg.settings.jwt.secret;

  # paths outside the state directory need to be granted write access explicitly
  extraWritePaths = lib.unique (
    lib.filter (p: p != null && !lib.hasPrefix stateDir p) [
      bookDir
      logDir
      (if dbFile != null then (dirOf dbFile) else null)
    ]
  );
in
{
  options.services.reader-server-rs = {
    enable = lib.mkEnableOption "reader-server-rs, a self-hosted reading server for txt/epub books with multi-user progress sync";

    package = lib.mkOption {
      type = lib.types.package;
      default = defaultPackage;
      description = "The reader-server-rs package to use.";
    };

    secretFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        File containing the JWT secret (a single line). It is merged into the
        generated config at service start time, so the secret never lands in
        the world-readable nix store. Preferred over `settings.jwt.secret`.
      '';
    };

    settings = lib.mkOption {
      type = lib.types.submodule {
        freeformType = settingsFormat.type;
        options = {
          server = {
            host = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Address to bind.";
            };
            port = lib.mkOption {
              type = lib.types.nullOr lib.types.port;
              default = null;
              description = "Port to bind.";
            };
          };

          db = {
            url = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = ''
                Database url. `sqlite:reader.db` is relative to the state
                directory (`${stateDir}`); use `sqlite:///abs/path.db` for an
                absolute path.
              '';
            };
            max_connections = lib.mkOption {
              type = lib.types.nullOr lib.types.ints.positive;
              default = null;
              description = "Maximum database connections.";
            };
          };

          storage = {
            book_dir = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Directory books are uploaded to (relative to the state directory).";
            };
            max_file_size = lib.mkOption {
              type = lib.types.nullOr lib.types.ints.positive;
              default = null;
              description = "Upload size limit per file, in bytes.";
            };
          };

          jwt = {
            secret = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = ''
                JWT signing secret. `secretFile` is preferred since this value
                ends up in the nix store. If neither is set, the app generates
                a random secret per boot — and `preStart` recreates config.json
                on every boot, so all tokens would be invalidated on restart;
                set one of the two explicitly.
              '';
            };
            expiration = lib.mkOption {
              type = lib.types.nullOr lib.types.ints.positive;
              default = null;
              description = "User token expiration in seconds (max 365 days).";
            };
            admin_expiration = lib.mkOption {
              type = lib.types.nullOr lib.types.ints.positive;
              default = null;
              description = "Admin token expiration in seconds (max 365 days).";
            };
          };

          log = {
            dir = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Log directory (relative to the state directory).";
            };
            rotation = lib.mkOption {
              type = lib.types.nullOr (
                lib.types.enum [
                  "hourly"
                  "daily"
                  "never"
                ]
              );
              default = null;
              description = ''Log rotation; "never" logs to stderr only.'';
            };
            level = lib.mkOption {
              type = lib.types.nullOr (
                lib.types.enum [
                  "trace"
                  "debug"
                  "info"
                  "warn"
                  "error"
                ]
              );
              default = null;
              description = ''
                Log level of the server itself; axum/tower-http log at warn.
                Set RUST_LOG via `systemd.services.reader-server-rs.environment`
                for full `EnvFilter` control (overrides this).
              '';
            };
          };

          rate_limit = {
            per_second = lib.mkOption {
              type = lib.types.nullOr lib.types.ints.positive;
              default = null;
              description = "Requests allowed per client IP per second (max 1000000).";
            };
            burst_size = lib.mkOption {
              type = lib.types.nullOr lib.types.ints.positive;
              default = null;
              description = "Token bucket burst capacity per client IP.";
            };
            trust_proxy_headers = lib.mkOption {
              type = lib.types.nullOr lib.types.bool;
              default = null;
              description = ''
                Trust X-Forwarded-For / X-Real-IP / Forwarded for rate limiting.
                Only enable behind a reverse proxy that overwrites these
                headers.
              '';
            };
          };
        };
      };
      description = ''
        reader-server-rs configuration, written to config.json. See
        https://github.com/lxl66566/reader-server-rs for all options.
        Unset options fall back to the app's built-in defaults.
      '';
      example = {
        server.port = 3000;
        storage.book_dir = "books";
        log.level = "debug";
        rate_limit.trust_proxy_headers = true;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        # an empty secret makes the app generate a fresh random one per boot,
        # invalidating all tokens on every restart — catch it at eval time
        assertion = cfg.secretFile != null || !(jwtSecret == null || jwtSecret == "");
        message = "services.reader-server-rs: set `secretFile` or a non-empty `settings.jwt.secret`.";
      }
    ];

    systemd.services.reader-server-rs = {
      description = "reader-server-rs self-hosted reading server";
      documentation = [ "https://github.com/lxl66566/reader-server-rs" ];
      after = [ "network.target" ];
      wants = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      # jq for merging secretFile into the generated config in preStart
      path = [ pkgs.jq ];

      # the app only reads ./config.json relative to its working directory,
      # so materialize it into the state directory (0600, it holds the JWT secret)
      preStart = ''
        umask 077
        if [ -f "$CREDENTIALS_DIRECTORY/jwt_secret" ]; then
          jq --rawfile secret "$CREDENTIALS_DIRECTORY/jwt_secret" \
            '.jwt.secret = ($secret | rtrimstr("\n"))' ${configFile} > config.json
        else
          cp ${configFile} config.json
        fi
        chmod 600 config.json
        ${lib.optionalString (dbFile != null) ''
          mkdir -p "${dirOf dbFile}"
        ''}
      '';

      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/reader-server";

        Restart = "on-failure";
        RestartSec = "5s";

        DynamicUser = true;
        StateDirectory = "reader-server-rs";
        WorkingDirectory = stateDir;
        ReadWritePaths = extraWritePaths;
        LoadCredential = lib.optional (cfg.secretFile != null) "jwt_secret:${toString cfg.secretFile}";

        StandardOutput = "journal";
        StandardError = "journal";
        SyslogIdentifier = "reader-server-rs";

        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = [ "@system-service" ];
        UMask = "0077";
      };
    };
  };
}
