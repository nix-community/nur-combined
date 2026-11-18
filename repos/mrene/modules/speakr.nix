{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.speakr;
  inherit (lib) mkOption types;

  toEnv = value: if lib.isBool value then lib.boolToString value else toString value;

  # Exports each credential as the environment variable it is named after.
  withSecrets = pkgs.writeShellScript "speakr-with-secrets" ''
    for file in "''${CREDENTIALS_DIRECTORY:-/nonexistent}"/*; do
      [ -e "$file" ] || continue
      export "''${file##*/}=$(< "$file")"
    done
    exec "$@"
  '';

  # Run once before the workers start so they do not race on the first schema
  # setup, then create the configured admin account (a no-op if it exists).
  init = pkgs.writeShellScript "speakr-init" ''
    set -eu
    ${lib.getExe' cfg.package "speakr-python"} -c 'import src.app'
    if [ -n "''${ADMIN_USERNAME:-}" ] && [ -n "''${ADMIN_EMAIL:-}" ] && [ -n "''${ADMIN_PASSWORD:-}" ]; then
      ${lib.getExe' cfg.package "speakr-python"} scripts/docker_create_admin.py
    fi
  '';
in
{
  options.services.speakr = {
    enable = lib.mkEnableOption "Speakr, a self-hosted transcription and note-taking service";

    package = mkOption {
      type = types.package;
      default = pkgs.callPackage ../pkgs/speakr/package.nix { };
      defaultText = lib.literalExpression "pkgs.callPackage <nur-packages/pkgs/speakr/package.nix> { }";
      description = "Speakr package to run.";
    };

    host = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Address the web server binds to.";
    };

    port = mkOption {
      type = types.port;
      default = 8899;
      description = "Port the web server listens on.";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open {option}`services.speakr.port` in the firewall.";
    };

    workers = mkOption {
      type = types.ints.positive;
      default = 3;
      description = "Number of gunicorn worker processes.";
    };

    threads = mkOption {
      type = types.ints.positive;
      default = 8;
      description = "Threads per worker; streaming responses hold one for their duration.";
    };

    user = mkOption {
      type = types.str;
      default = "speakr";
      description = "User the service runs as; created when left at the default.";
    };

    group = mkOption {
      type = types.str;
      default = "speakr";
      description = "Group the service runs as; created when left at the default.";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/speakr";
      description = ''
        Directory holding the SQLite database, the generated secret key, VAPID
        keys and, unless {option}`services.speakr.settings` moves them, uploads,
        exports and the auto-process watch folder.
      '';
    };

    settings = mkOption {
      type = types.submodule {
        freeformType = types.attrsOf (
          types.nullOr (
            types.oneOf [
              types.bool
              types.int
              types.str
              types.path
            ]
          )
        );
      };
      default = { };
      example = {
        TEXT_MODEL_BASE_URL = "https://openrouter.ai/api/v1";
        TEXT_MODEL_NAME = "openai/gpt-4o-mini";
        TRANSCRIPTION_MODEL = "gpt-4o-transcribe-diarize";
        ALLOW_REGISTRATION = false;
        TIMEZONE = "America/Toronto";
      };
      description = ''
        Environment variables configuring Speakr, as documented in its
        `config/env.*.example` files. Booleans become `true`/`false`; `null`
        unsets a variable. Put API keys and passwords in
        {option}`services.speakr.secretFiles` instead.
      '';
    };

    secretFiles = mkOption {
      type = types.attrsOf types.path;
      default = { };
      example = lib.literalExpression ''
        {
          TEXT_MODEL_API_KEY = config.sops.secrets."speakr/text-model-api-key".path;
          ADMIN_PASSWORD = config.sops.secrets."speakr/admin-password".path;
        }
      '';
      description = ''
        Environment variables read from files, such as sops-nix secrets. The
        files are passed as systemd credentials, so they may stay readable by
        root only. Setting `ADMIN_PASSWORD` together with the `ADMIN_USERNAME`
        and `ADMIN_EMAIL` settings creates that admin account on startup if it
        does not exist. Without `SECRET_KEY`, Speakr generates one under
        {option}`services.speakr.dataDir`.
      '';
    };

    environmentFiles = mkOption {
      type = types.listOf types.path;
      default = [ ];
      description = ''
        Files of `NAME=value` lines added to the environment, for example a
        sops-nix template; see {manpage}`systemd.exec(5)` `EnvironmentFile=`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.speakr.settings = {
      SQLALCHEMY_DATABASE_URI = lib.mkDefault "sqlite:///${cfg.dataDir}/instance/transcriptions.db";
      UPLOAD_FOLDER = lib.mkDefault "${cfg.dataDir}/uploads";
      CONFIG_DIR = lib.mkDefault "${cfg.dataDir}/config";
      AUTO_PROCESS_WATCH_DIR = lib.mkDefault "${cfg.dataDir}/auto-process";
      AUTO_EXPORT_DIR = lib.mkDefault "${cfg.dataDir}/exports";
      HF_HOME = lib.mkDefault "${cfg.dataDir}/instance/huggingface";
    };

    users.users = lib.mkIf (cfg.user == "speakr") {
      speakr = {
        isSystemUser = true;
        inherit (cfg) group;
        home = cfg.dataDir;
      };
    };
    users.groups = lib.mkIf (cfg.group == "speakr") { speakr = { }; };

    systemd.tmpfiles.settings.speakr =
      lib.genAttrs
        [
          cfg.dataDir
          "${cfg.dataDir}/instance"
        ]
        (_: {
          d = {
            inherit (cfg) user group;
            mode = "0750";
          };
        });

    systemd.services.speakr = {
      description = "Speakr transcription service";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      environment = lib.mapAttrs (_: toEnv) (lib.filterAttrs (_: v: v != null) cfg.settings);

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = "${cfg.package}/share/speakr";
        EnvironmentFile = cfg.environmentFiles;
        LoadCredential = lib.mapAttrsToList (name: path: "${name}:${path}") cfg.secretFiles;
        ExecStartPre = "${withSecrets} ${init}";
        ExecStart = lib.escapeShellArgs [
          withSecrets
          (lib.getExe cfg.package)
          "--bind"
          "${cfg.host}:${toString cfg.port}"
          "--workers"
          cfg.workers
          "--worker-class"
          "gthread"
          "--threads"
          cfg.threads
          # Transcription and summary requests can run for minutes.
          "--timeout"
          "600"
        ];
        Restart = "on-failure";
        # Imports, migrations and the first model download take a while.
        TimeoutStartSec = "10min";

        UMask = "0027";
        ReadWritePaths = [ cfg.dataDir ];
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        NoNewPrivileges = true;
        LockPersonality = true;
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];
        SystemCallArchitectures = "native";
        SystemCallFilter = [
          "@system-service"
          "~@privileged"
        ];
        CapabilityBoundingSet = "";
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];
  };
}
