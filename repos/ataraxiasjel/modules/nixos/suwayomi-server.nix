{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.services.suwayomi-server;
  inherit (lib)
    mkOption
    mkEnableOption
    mkIf
    types
    ;

  format = pkgs.formats.hocon { };

  configFile = format.generate "server.conf" (
    lib.filterAttrsRecursive (_: x: x != null) (
      cfg.settings
      // {
        server = removeAttrs cfg.settings.server [
          "authPasswordFile"
          "basicAuthEnabled"
          "basicAuthPasswordFile"
          "basicAuthUsername"
        ];
      }
    )
  );
  serverConf = "${cfg.dataDir}/server.conf";
in
{
  options = {
    services.suwayomi-server = {
      enable = mkEnableOption "Suwayomi, a free and open source manga reader server that runs extensions built for Tachiyomi";

      package = lib.mkPackageOption pkgs "suwayomi-server" { };

      dataDir = mkOption {
        type = types.path;
        default = "/var/lib/suwayomi-server";
        example = "/var/data/mangas";
        description = ''
          The path to the data directory in which Suwayomi-Server will download scans.
        '';
      };

      user = mkOption {
        type = types.str;
        default = "suwayomi";
        example = "root";
        description = ''
          User account under which Suwayomi-Server runs.
        '';
      };

      group = mkOption {
        type = types.str;
        default = "suwayomi";
        example = "medias";
        description = ''
          Group under which Suwayomi-Server runs.
        '';
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to open the firewall for the port in {option}`services.suwayomi-server.settings.server.port`.
        '';
      };

      settings = mkOption {
        type = types.submodule {
          freeformType = format.type;
          options.server = {
            ip = mkOption {
              type = types.str;
              default = "0.0.0.0";
              example = "127.0.0.1";
              description = ''
                The ip that Suwayomi will bind to.
              '';
            };

            port = mkOption {
              type = types.port;
              default = 8080;
              example = 4567;
              description = ''
                The port that Suwayomi will listen to.
              '';
            };

            authMode = mkOption {
              type = types.enum [
                "none"
                "basic_auth"
                "simple_login"
                "ui_auth"
              ];
              default = "none";
              description = ''
                The auth mode to use when authenticating with the server.
                See <https://github.com/Suwayomi/Suwayomi-Server/blob/v2.3.2243/docs/Configuring-Suwayomi%E2%80%90Server.md#authentication>
                for more information.
              '';
            };

            authUsername = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = ''
                The username value that you have to provide when authenticating.
              '';
            };

            # NOTE: this is not a real upstream option
            authPasswordFile = mkOption {
              type = types.nullOr types.externalPath;
              default = null;
              example = "/var/secrets/suwayomi-server-password";
              description = ''
                The password file containing the value that you have to provide when authenticating.
              '';
            };

            downloadAsCbz = mkOption {
              type = types.bool;
              default = false;
              description = ''
                Download chapters as `.cbz` files.
              '';
            };

            extensionRepos = mkOption {
              type = types.listOf types.str;
              default = [ ];
              example = [
                "https://raw.githubusercontent.com/MY_ACCOUNT/MY_REPO/repo/index.min.json"
              ];
              description = ''
                URL of repositories from which the extensions can be installed.
              '';
            };

            localSourcePath = mkOption {
              type = types.path;
              default = cfg.dataDir;
              defaultText = lib.literalExpression "suwayomi-server.dataDir";
              example = "/var/data/local_mangas";
              description = ''
                Path to the local source folder.
              '';
            };

            systemTrayEnabled = mkOption {
              type = types.bool;
              default = false;
              description = ''
                Whether to enable a system tray icon, if possible.
              '';
            };
          };
        };
        description = ''
          Configuration to write to {file}`server.conf`.
          See <https://github.com/Suwayomi/Suwayomi-Server/wiki/Configuring-Suwayomi-Server> for more information.
        '';
        default = { };
        example = {
          server.socksProxyEnabled = true;
          server.socksProxyHost = "yourproxyhost.com";
          server.socksProxyPort = "8080";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion =
          with cfg.settings.server;
          authMode != "none"
          -> (authUsername != null && authPasswordFile != null && !(cfg.settings.server ? authPassword));
        message = ''
          [suwayomi-server]: the username and the password file cannot be null when the basic auth is enabled
        '';
      }
    ];

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.settings.server.port ];

    users.groups = mkIf (cfg.group == "suwayomi") {
      suwayomi = { };
    };

    users.users = mkIf (cfg.user == "suwayomi") {
      suwayomi = {
        group = cfg.group;
        home = cfg.dataDir;
        description = "Suwayomi Daemon user";
        isSystemUser = true;
      };
    };

    systemd.tmpfiles.settings = {
      "10-suwayomi-server"."${cfg.dataDir}".d = {
        mode = "0700";
        inherit (cfg) user group;
      };
    };

    systemd.services.suwayomi-server = {
      description = "A free and open source manga reader server that runs extensions built for Tachiyomi.";

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      environment = {
        JAVA_TOOL_OPTIONS = "-Dsuwayomi.tachidesk.config.server.rootDir=${cfg.dataDir}";
      };

      preStart = ''
        # Suwayomi-Server rewrites server.conf on startup (updateUserConfig),
        # so it must be a writable copy, not a symlink into /nix/store.
        mkdir -p "${cfg.dataDir}"
        chown "${cfg.user}:${cfg.group}" "${cfg.dataDir}"
        chmod 0700 "${cfg.dataDir}"
        rm -f "${serverConf}"
        # Clean up the pre-rootDir symlink location so a stale link
        # is never mistaken for the real config.
        rm -f "${cfg.dataDir}/.local/share/Tachidesk/server.conf"
        install -Dm600 -o "${cfg.user}" -g "${cfg.group}" "${configFile}" "${serverConf}"
      '';

      script =
        (lib.optionalString (cfg.settings.server.authMode != "none") ''
          set -u
          JAVA_TOOL_OPTIONS="''${JAVA_TOOL_OPTIONS:+$JAVA_TOOL_OPTIONS }-Dsuwayomi.tachidesk.config.server.authPassword=$(cat "$CREDENTIALS_DIRECTORY/TACHIDESK_SERVER_AUTH_PASSWORD")"
        '')
        + ''
          ${lib.getExe cfg.package}
        '';

      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";

        StateDirectory = mkIf (cfg.dataDir == "/var/lib/suwayomi-server") "suwayomi-server";
        LoadCredential = mkIf (cfg.settings.server.authMode != "none") [
          "TACHIDESK_SERVER_AUTH_PASSWORD:${cfg.settings.server.authPasswordFile}"
        ];

        # Hardening
        User = cfg.user;
        Group = cfg.group;
        CapabilityBoundingSet = "";
        SystemCallFilter = [ "@system-service" ];

        ReadWritePaths = [ cfg.dataDir ];
        NoNewPrivileges = true;
        ProtectClock = true;
        RestrictNamespaces = true;
        RestrictSUIDSGID = true;
        LockPersonality = true;
        RestrictRealtime = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];
        # Java limitations don't allow the
        # following hardening option
        # MemoryDenyWriteExecute = true;
        ProtectHostname = true;

        ProtectSystem = "strict";
        PrivateTmp = true;
        ProtectHome = true;
        PrivateDevices = true;
        ProtectControlGroups = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectProc = "invisible";
      };
    };
  };

  meta = {
    maintainers = with lib.maintainers; [
      ratcornu
      nanoyaki
      ataraxiasjel
    ];
    doc = ./suwayomi-server.md;
  };
}
