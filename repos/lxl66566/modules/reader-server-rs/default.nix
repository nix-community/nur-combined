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
  configFile = settingsFormat.generate "reader-server-rs.json" cfg.settings;

  # relative paths in the config resolve against the working directory (stateDir);
  # normalize to absolute to know which extra paths need write access
  absPath = p: if lib.hasPrefix "/" (toString p) then toString p else "${stateDir}/${toString p}";

  bookDir = absPath cfg.settings.storage.book_dir;
  logDir = absPath cfg.settings.log.dir;

  # "sqlite:///abs/path.db" -> "/abs/path.db"; "sqlite:reader.db" -> stateDir/reader.db
  dbFile =
    let
      url = cfg.settings.db.url;
    in
    if lib.hasPrefix "sqlite:///" url then
      lib.removePrefix "sqlite://" url
    else if lib.hasPrefix "sqlite:" url then
      absPath (lib.removePrefix "sqlite:" url)
    else
      null;

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
              type = lib.types.str;
              description = "Address to bind.";
              default = "0.0.0.0";
            };
            port = lib.mkOption {
              type = lib.types.port;
              description = "Port to bind.";
              default = 3000;
            };
          };

          db = {
            url = lib.mkOption {
              type = lib.types.str;
              description = ''
                Database url. `sqlite:reader.db` is relative to the state
                directory (`${stateDir}`); use `sqlite:///abs/path.db` for an
                absolute path.
              '';
              default = "sqlite:reader.db";
            };
            max_connections = lib.mkOption {
              type = lib.types.ints.positive;
              description = "Maximum database connections.";
              default = 10;
            };
          };

          storage = {
            book_dir = lib.mkOption {
              type = lib.types.str;
              description = "Directory books are uploaded to (relative to the state directory).";
              default = "books";
            };
            max_file_size = lib.mkOption {
              type = lib.types.ints.positive;
              description = "Upload size limit per file, in bytes.";
              default = 52428800;
            };
          };

          jwt = {
            secret = lib.mkOption {
              type = lib.types.str;
              description = ''
                JWT signing secret. Must be non-empty; the app refuses to start
                otherwise. `secretFile` is preferred since this value ends up in
                the nix store.
              '';
              default = "";
            };
            expiration = lib.mkOption {
              type = lib.types.ints.positive;
              description = "User token expiration in seconds (max 365 days).";
              default = 2592000;
            };
            admin_expiration = lib.mkOption {
              type = lib.types.ints.positive;
              description = "Admin token expiration in seconds (max 365 days).";
              default = 604800;
            };
          };

          log = {
            dir = lib.mkOption {
              type = lib.types.str;
              description = "Log directory (relative to the state directory).";
              default = "logs";
            };
            rotation = lib.mkOption {
              type = lib.types.enum [
                "hourly"
                "daily"
                "never"
              ];
              description = ''Log rotation; "never" logs to stderr only.'';
              default = "daily";
            };
          };

          rate_limit = {
            per_second = lib.mkOption {
              type = lib.types.ints.positive;
              description = "Requests allowed per client IP per second (max 1000000).";
              default = 20;
            };
            burst_size = lib.mkOption {
              type = lib.types.ints.positive;
              description = "Token bucket burst capacity per client IP.";
              default = 70;
            };
            trust_proxy_headers = lib.mkOption {
              type = lib.types.bool;
              description = ''
                Trust X-Forwarded-For / X-Real-IP / Forwarded for rate limiting.
                Only enable behind a reverse proxy that overwrites these
                headers.
              '';
              default = false;
            };
          };
        };
      };
      description = "reader-server-rs configuration, written to config.json. See https://github.com/lxl66566/reader-server-rs for all options.";
      example = {
        server.port = 3000;
        storage.book_dir = "books";
        rate_limit.trust_proxy_headers = true;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # the app bails out on an empty secret, so catch it at eval time
    assertions = [
      {
        assertion = cfg.secretFile != null || cfg.settings.jwt.secret != "";
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
