{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib)
    getExe
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    optionalAttrs
    types
    ;
  cfg = config.services.remark42;

  # Create environment file content from settings
  environmentContent = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: value: if value != null then "${name}=${toString value}" else "") (
      lib.filterAttrs (name: value: value != null) cfg.environment
    )
  );

  environmentFile = pkgs.writeText "remark42.env" environmentContent;
in
{
  options.services.remark42 = {
    enable = mkEnableOption "remark42 comment engine";

    # package = mkPackageOption pkgs "remark42" { };

    package = mkOption {
      type = types.package;
      default = pkgs.callPackage ../../pkgs/remark42 {
        inherit (cfg) customCSS;
      };
    };

    user = mkOption {
      type = types.str;
      default = "remark42";
      description = "User to run remark42 as";
    };

    group = mkOption {
      type = types.str;
      default = "remark42";
      description = "Group to run remark42 as";
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/remark42";
      description = "Directory where remark42 stores its data";
    };

    environmentFile = mkOption {
      type = with types; nullOr str;
      description = lib.mdDoc ''
        File containing environment variables for remark42, in the
        format of an EnvironmentFile as described in systemd.exec(5).

        This should contain sensitive configuration like:
        SECRET, AUTH_*_CID, AUTH_*_CSEC, SMTP_PASSWORD, etc.

        SECRET is mandatory: the shared secret key used to sign JWT, should be a random, long,
        hard-to-guess string. You could run `head -c 32 /dev/random | base64` to get one.
      '';
      default = null;
    };

    url = mkOption {
      type = types.str;
      description = "URL pointing to your remark42 server (required)";
      example = "https://comments.example.com";
    };

    sites = mkOption {
      type = types.listOf types.str;
      default = [ "remark" ];
      description = "Site name(s) that remark42 will serve";
      example = "[\"mysite\", \"blog\"]";
    };

    port = mkOption {
      type = types.port;
      default = 8080;
      description = "Port for remark42 to listen on";
    };

    address = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Address for remark42 to bind to";
    };

    debug = mkOption {
      type = types.bool;
      default = false;
      description = "Enable debug mode";
    };

    anonymousAuth = mkOption {
      type = types.bool;
      default = false;
      description = "Enable anonymous commenting";
    };

    maxCommentSize = mkOption {
      type = types.int;
      default = 2048;
      description = "Maximum comment size in characters";
    };

    editTimeLimit = mkOption {
      type = types.str;
      default = "5m";
      description = "Time limit for editing comments";
    };

    environment = mkOption {
      type = types.attrsOf (
        types.nullOr (
          types.oneOf [
            types.str
            types.int
            types.bool
          ]
        )
      );
      default = { };
      description = ''
        Additional environment variables for remark42. Full list on
        https://remark42.com/docs/configuration/parameters/
      '';
      example = ''
        {
          NOTIFY_ADMINS = "email";
          SMTP_HOST = "smtp.gmail.com";
          SMTP_PORT = 587;
          EMOJI = true;
        }
      '';
    };

    customCSS = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Additional CSS rules to append to remark.css (change requires package rebuild)";
      example = ''
        :root {
          --primary-color: 0, 170, 170;
          --primary-brighter-color: 0, 153, 153;
          --primary-darker-color: 0, 102, 102;
          --primary-text-color: 38, 38, 38;
          --secondary-text-color: 100, 116, 139;
          --secondary-darker-text-color: 150, 150, 150;
          --primary-background-color: 255, 255, 255;
        }

        :root .dark {
          --primary-color: 0, 153, 153;
          --primary-brighter-color: 0, 170, 170;
          --primary-text-color: 241, 245, 249;
          --primary-background-color: 38, 38, 38;
          --secondary-text-color: 209, 213, 219;
          --error-color: #ffa0a0;
          --line-brighter-color: var(--color11);
          --text-color: var(--white-color);
        }

        .comment-form {
          border-radius: 4px;
        }
      '';
    };

    backup = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable automatic backups";
      };

      path = mkOption {
        type = types.str;
        default = "${cfg.dataDir}/backup";
        description = "Path where backups are stored";
      };

      maxFiles = mkOption {
        type = types.int;
        default = 10;
        description = "Maximum number of backup files to keep";
      };
    };
  };

  config = mkIf cfg.enable {
    # Create user and group
    users.users.${cfg.user} = {
      description = "remark42 service user";
      inherit (cfg) group;
      home = cfg.dataDir;
      createHome = true;
      isSystemUser = true;
    };

    users.groups.${cfg.group} = { };

    # Ensure data directory exists with correct permissions
    # systemd.tmpfiles.rules = [
    #   "d ${cfg.dataDir} 0750 ${cfg.user} ${cfg.group} - -"
    #   "d ${cfg.backup.path} 0750 ${cfg.user} ${cfg.group} - -"
    # ];

    systemd.services.remark42 = {
      description = "Remark42 comment engine";
      requires = [ "network-online.target" ];
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      environment = {
        REMARK_URL = cfg.url;
        SITE = lib.concatStringsSep "," cfg.sites;
        REMARK_PORT = toString cfg.port;
        REMARK_ADDRESS = cfg.address;
        STORE_BOLT_PATH = cfg.dataDir;
        BACKUP_PATH = cfg.backup.path;
        MAX_BACKUP_FILES = toString cfg.backup.maxFiles;
        MAX_COMMENT_SIZE = toString cfg.maxCommentSize;
        EDIT_TIME = cfg.editTimeLimit;
        DEBUG = lib.boolToString cfg.debug;
        AUTH_ANON = lib.boolToString cfg.anonymousAuth;
      } // cfg.environment;

      serviceConfig =
        {
          ExecStart = "${getExe cfg.package} server";
          Type = "simple";
          User = cfg.user;
          Group = cfg.group;
          Restart = "always";
          RestartSec = "5s";
          WorkingDirectory = cfg.dataDir;

          # Security hardening
          CapabilityBoundingSet = "";
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateTmp = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          ProtectSystem = "strict";
          ReadWritePaths = [ cfg.dataDir ];
          RemoveIPC = true;
          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
          ];
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          SystemCallFilter = [
            "@system-service"
            "~@privileged"
          ];
          UMask = "0077";
        }
        // optionalAttrs (cfg.environmentFile != null) {
          EnvironmentFile = cfg.environmentFile;
        };
    };

    # Open firewall port if needed
    # networking.firewall.allowedTCPPorts = mkIf (cfg.address != "127.0.0.1") [cfg.port];
  };

  meta = {
    maintainers = with lib.maintainers; [ serpent213 ];
    doc = ./remark42.md;
  };
}
