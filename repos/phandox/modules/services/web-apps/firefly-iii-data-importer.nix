{ pkgs, config, lib, ... }:

let
  inherit (lib) optionalString mkDefault mkIf mkOption mkEnableOption literalExpression;
  inherit (lib.types) nullOr attrsOf oneOf str int bool path package enum submodule;
  inherit (lib.strings) concatLines removePrefix toShellVars removeSuffix hasSuffix;
  inherit (lib.attrsets) mapAttrsToList attrValues genAttrs filterAttrs mapAttrs' nameValuePair;
  inherit (builtins) isInt isString toString typeOf mapAttrs;

  cfg = config.services.firefly-iii-data-importer;

  user = cfg.user;
  group = cfg.group;

  defaultUser = "firefly-iii-data-importer";
  defaultGroup = "firefly-iii-data-importer";
  env-file-values = mapAttrs' (n: v: nameValuePair (removeSuffix "_FILE" n) v)
    (filterAttrs (n: v: hasSuffix "_FILE" n) cfg.settings);
  env-nonfile-values = filterAttrs (n: v: ! hasSuffix "_FILE" n) cfg.settings;

  fileenv-func = ''
    set -a
    ${toShellVars env-nonfile-values}
    ${concatLines (mapAttrsToList (n: v: "${n}=\"$(< ${v})\"") env-file-values)}
    set +a
  '';

  firefly-iii-data-importer-setup = pkgs.writeShellScript "firefly-iii-setup.sh" ''
    ${fileenv-func}
  '';

  commonServiceConfig = {
    Type = "oneshot";
    User = user;
    Group = group;
    StateDirectory = "${removePrefix "/var/lib/" cfg.dataDir}";
    WorkingDirectory = cfg.package;
    PrivateTmp = true;
    PrivateDevices = true;
    CapabilityBoundingSet = "";
    AmbientCapabilities = "";
    ProtectSystem = "strict";
    ProtectKernelTunables = true;
    ProtectKernelModules = true;
    ProtectControlGroups = true;
    ProtectClock = true;
    ProtectHostname = true;
    ProtectHome = "tmpfs";
    ProtectKernelLogs = true;
    ProtectProc = "invisible";
    ProcSubset = "pid";
    PrivateNetwork = false;
    RestrictAddressFamilies = "AF_INET AF_INET6 AF_UNIX";
    SystemCallArchitectures = "native";
    SystemCallFilter = [
      "@system-service @resources"
      "~@obsolete @privileged"
    ];
    RestrictSUIDSGID = true;
    RemoveIPC = true;
    NoNewPrivileges = true;
    RestrictRealtime = true;
    RestrictNamespaces = true;
    LockPersonality = true;
    PrivateUsers = true;
  };

  dataImporterPackage = pkgs.nur.repos.phandox.firefly-iii-data-importer;

in {

  options.services.firefly-iii-data-importer = {

    enable = mkEnableOption "Firefly III Data Importer can import data to Firefly III";

    user = mkOption {
      type = str;
      default = defaultUser;
      description = "User account under which firefly-iii-data-importer runs.";
    };

    group = mkOption {
      type = str;
      default = if cfg.enableNginx then "nginx" else defaultGroup;
      defaultText = "If `services.firefly-iii-data-importer.enableNginx` is true then `nginx` else ${defaultGroup}";
      description = ''
        Group under which firefly-iii-data-importer runs. It is best to set this to the group
        of whatever webserver is being used as the frontend.
      '';
    };

    dataDir = mkOption {
      type = path;
      default = "/var/lib/firefly-iii-data-importer";
      description = ''
        The place where firefly-iii-data-importer stores its state.
      '';
    };

    package = mkOption {
      type = package;
      default = pkgs.nur.repos.phandox.firefly-iii-data-importer;
      defaultText = literalExpression "nur.repos.phandox.firefly-iii-data-importer";
      description = ''
        The firefly-iii-data-importer package served by php-fpm and the webserver of choice.
        This option can be used to point the webserver to the correct root. It
        may also be used to set the package to a different version, say a
        development version.
      '';
      apply = firefly-iii-data-importer : firefly-iii-data-importer.override (prev: {
        dataDir = cfg.dataDir;
      });
    };

    enableNginx = mkOption {
      type = bool;
      default = false;
      description = ''
        Whether to enable nginx or not. If enabled, an nginx virtual host will
        be created for access to firefly-iii-data-importer. If not enabled, then you may use
        `''${config.services.firefly-iii-data-importer.package}` as your document root in
        whichever webserver you wish to setup.
      '';
    };

    virtualHost = mkOption {
      type = str;
      default = "localhost";
      description = ''
        The hostname at which you wish firefly-iii-data-importer to be served. If you have
        enabled nginx using `services.firefly-iii-data-importer.enableNginx` then this will
        be used.
      '';
    };

    poolConfig = mkOption {
      type = attrsOf (oneOf [ str int bool ]);
      default = {
        "pm" = "dynamic";
        "pm.max_children" = 32;
        "pm.start_servers" = 2;
        "pm.min_spare_servers" = 2;
        "pm.max_spare_servers" = 4;
        "pm.max_requests" = 500;
      };
      description = ''
        Options for the Firefly III PHP pool. See the documentation on <literal>php-fpm.conf</literal>
        for details on configuration directives.
      '';
    };

    settings = mkOption {
      default = {};
      description = ''
        Options for firefly-iii-data-importer configuration. Refer to
        <https://github.com/firefly-iii/data-importer/blob/main/.env.example> for
        details on supported values. All <option>_FILE values supported by
        upstream are supported here.

        APP_URL will be the same as `services.firefly-iii-data-importer.virtualHost` if the
        former is unset in `services.firefly-iii-data-importer.settings`.
      '';
      example = literalExpression ''
        {
          TZ = "Europe/Prague";
          LOG_LEVEL = "warning";
          TRUSTED_PROXIES = "**";
          FIREFLY_III_ACCESS_TOKEN_FILE = "/var/lib/firefly-iii-data-importer/firefly-iii-access-token";
          NORDIGEN_ID_FILE = "/var/lib/firefly-iii-data-importer/nordigen-id";
          NORDIGEN_KEY_FILE = "/var/lib/firefly-iii-data-importer/nordigen-key";
          FIREFLY_III_URL = "https://firefly-iii.example.com";
        }
      '';
      type = submodule {
        freeformType = attrsOf (oneOf [str int bool]);
        options = {
          TZ = mkOption {
            type = str;
            default = "Europe/Prague";
            example = "Europe/Prague";
            description = ''
              The timezone of the application. This should be set to the timezone
              of the server.
            '';
          };
          LOG_LEVEL = mkOption {
            type = enum [ "emergency" "alert" "critical" "error" "warning" "notice" "info" "debug" ];
            default = "warning";
            defaultText = ''
              `warning` to keep only important messages in the logs.
            '';
            description = ''
              The log level of the application. Possible values are "emergency",
              "alert", "critical", "error", "warning", "notice", "info" and
              "debug".
            '';
          };
          TRUSTED_PROXIES = mkOption {
            type = str;
            default = "**";
            defaultText = ''
              "Trust all proxies '**' by default"
            '';
            description = ''
            TODO
            '';
          };
          # Don't remove suffix file and try it with embedded _FILE
          FIREFLY_III_ACCESS_TOKEN_FILE = mkOption {
            type = path;
            description = ''
              The access token for the Firefly III API. This is used to authenticate
              the data importer with the Firefly III API.
            '';
          };
          NORDIGEN_ID_FILE = mkOption {
            type = path;
            description = ''
              Path to the file with The Nordigen API ID. This is used to authenticate the data importer
              with the Nordigen API.
            '';
          };
          NORDIGEN_KEY_FILE= mkOption {
            type = path;
            description = ''
              Path to the file with Nordigen API key. This is used to authenticate the data importer
              with the Nordigen API.
            '';
          };
          FIREFLY_III_URL = mkOption {
            type = str;
            default = if cfg.virtualHost == "localhost" then "http://${cfg.virtualHost}"
                      else "https://${cfg.virtualHost}";
            defaultText = ''
              http(s)://''${config.services.firefly-iii-data-importer.virtualHost}
            '';
            description = ''
              The APP_URL used by firefly-iii-data-importer internally. Please make sure this
              URL matches the external URL of your Firefly III installation. It
              is used to validate specific requests and to generate URLs in
              emails.
            '';
          };
        };
      };
    };
  };


  config = mkIf cfg.enable {

    services.phpfpm.pools.firefly-iii-data-importer = {
      inherit user group;
      phpPackage = cfg.package.phpPackage;
      phpOptions = ''
        log_errors = on
      '';
      settings = {
        "listen.mode" = "0660";
        "listen.owner" = user;
        "listen.group" = group;
        "clear_env" = "no";
      } // cfg.poolConfig;
    };

    systemd.services.firefly-iii-data-importer-setup = {
      requiredBy = [ "phpfpm-firefly-iii-data-importer.service" ];
      before = [ "phpfpm-firefly-iii-data-importer.service" ];
      serviceConfig = {
        ExecStart = firefly-iii-data-importer-setup;
        RuntimeDirectory = "phpfpm";
        RuntimeDirectoryPreserve = true;
        RemainAfterExit = true;
      } // commonServiceConfig;
      unitConfig.JoinsNamespaceOf = "phpfpm-firefly-iii-data-importer.service";
      restartTriggers = [ cfg.package ];
    };

    services.nginx = mkIf cfg.enableNginx {
      enable = true;
      recommendedTlsSettings = mkDefault true;
      recommendedOptimisation = mkDefault true;
      recommendedGzipSettings = mkDefault true;
      virtualHosts.${cfg.virtualHost} = {
        root = "${cfg.package}/public";
        locations = {
          "/" = {
            tryFiles = "$uri $uri/ /index.php?$query_string";
            index = "index.php";
            extraConfig = ''
              sendfile off;
            '';
          };
          "~ \.php$" = {
            extraConfig = ''
              include ${config.services.nginx.package}/conf/fastcgi_params ;
              fastcgi_param SCRIPT_FILENAME $request_filename;
              fastcgi_param modHeadersAvailable true; #Avoid sending the security headers twice
              fastcgi_pass unix:${config.services.phpfpm.pools.firefly-iii-data-importer.socket};
            '';
          };
        };
      };
    };

    systemd.tmpfiles.settings."10-firefly-iii-data-importer" = genAttrs [
      "${cfg.dataDir}/storage"
      "${cfg.dataDir}/storage/app"
      "${cfg.dataDir}/storage/database"
      "${cfg.dataDir}/storage/export"
      "${cfg.dataDir}/storage/framework"
      "${cfg.dataDir}/storage/framework/cache"
      "${cfg.dataDir}/storage/framework/sessions"
      "${cfg.dataDir}/storage/framework/views"
      "${cfg.dataDir}/storage/logs"
      "${cfg.dataDir}/storage/uploads"
      "${cfg.dataDir}/cache"
    ] (n: {
      d = {
        group = group;
        mode = "0700";
        user = user;
      };
    }) // {
      "${cfg.dataDir}".d = {
        group = group;
        mode = "0710";
        user = user;
      };
    };

    users = {
      users = mkIf (user == defaultUser) {
        ${defaultUser} = {
          description = "firefly-iii-data-importer service user";
          inherit group;
          isSystemUser = true;
          home = cfg.dataDir;
        };
      };
      groups = mkIf (group == defaultGroup) {
        ${defaultGroup} = {};
      };
    };
  };
}
