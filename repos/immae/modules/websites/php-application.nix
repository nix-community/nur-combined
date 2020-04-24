{ lib, config, ... }:
with lib;
let
  cfg = config.services.phpApplication;
  cfgByEnv = lists.groupBy (x: x.websiteEnv) (builtins.attrValues cfg.apps);
in
{
  options = with types; {
    services.phpApplication.apps = mkOption {
      default = {};
      description = ''
        php applications to define
        '';
      type = attrsOf (submodule {
        options = {
          varDir = mkOption {
            type = nullOr path;
            description = ''
              Path to application’s vardir.
              '';
          };
          varDirPaths = mkOption {
            type = attrsOf str;
            default = {};
            description = ''
              Map of additional folders => mode to create under varDir
              '';
          };
          mode = mkOption {
            type = str;
            default = "0700";
            description = ''
              Mode to apply to the vardir
              '';
          };
          phpSession = mkOption {
            type = bool;
            default = true;
            description = "Handle phpsession files separately in vardir";
          };
          phpListen = mkOption {
            type = nullOr str;
            default = null;
            description = "Name of the socket to listen to. Defaults to app name if null";
          };
          phpPool = mkOption {
            type = attrsOf str;
            default = {};
            description = "Pool configuration to append";
          };
          phpEnv = mkOption {
            type = attrsOf str;
            default = {};
            description = "Pool environment to append";
          };
          phpOptions = mkOption {
            type = lines;
            default = "";
            description = "php configuration to append";
          };
          phpOpenbasedir = mkOption {
            type = listOf path;
            default = [];
            description = ''
              paths to add to php open_basedir configuration in addition to app and vardir
              '';
          };
          phpWatchFiles = mkOption {
            type = listOf path;
            default = [];
            description = ''
              Path to other files to watch to trigger preStart scripts
              '';
          };
          websiteEnv = mkOption {
            type = str;
            description = ''
              website instance name to use
              '';
          };
          httpdUser = mkOption {
            type = str;
            default = config.services.httpd.user;
            description = ''
              httpd user to run the prestart scripts as.
              '';
          };
          httpdGroup = mkOption {
            type = str;
            default = config.services.httpd.group;
            description = ''
              httpd group to run the prestart scripts as.
              '';
          };
          httpdWatchFiles = mkOption {
            type = listOf path;
            default = [];
            description = ''
              Path to other files to watch to trigger httpd reload
              '';
          };
          app = mkOption {
            type = path;
            description = ''
              Path to application root
              '';
          };
          webappName = mkOption {
            type = nullOr str;
            default = null;
            description = ''
              Alias name for the app, to be used in services.websites.webappDirs
              '';
          };
          webRoot = mkOption {
            type = nullOr path;
            description = ''
              Path to the web root path of the application. May differ from the application itself (usually a subdirectory)
              '';
          };
          preStartActions = mkOption {
            type = listOf str;
            default = [];
            description = ''
              List of actions to run as apache user at preStart when
              whatchFiles or app dir changed.
              '';
          };
          serviceDeps = mkOption {
            type = listOf str;
            default = [];
            description = ''
              List of systemd services this application depends on
              '';
          };
        };
      });
    };
    # Read-only variables
    services.phpApplication.phpListenPaths = mkOption {
      type = attrsOf path;
      default = attrsets.mapAttrs' (name: icfg: attrsets.nameValuePair
        name config.services.phpfpm.pools."${name}".socket
      ) cfg.apps;
      readOnly = true;
      description = ''
        Full paths to listen for php
        '';
    };
    services.phpApplication.webappDirs = mkOption {
      type = attrsOf path;
      default = attrsets.filterAttrs (n: v: builtins.hasAttr n cfg.apps) config.services.websites.webappDirsPaths;
      readOnly = true;
      description = ''
        Stable name webapp dirs for httpd
        '';
    };
  };

  config = {
    services.websites.env = attrsets.mapAttrs' (name: cfgs: attrsets.nameValuePair
      name {
        modules = [ "proxy_fcgi" ];
        watchPaths = builtins.concatLists (map (c: c.httpdWatchFiles) cfgs);
      }
    ) cfgByEnv;

    services.phpfpm.pools = attrsets.mapAttrs' (name: icfg: attrsets.nameValuePair
      name {
        user = icfg.httpdUser;
        group = icfg.httpdUser;
        settings = {
          "listen.owner" = icfg.httpdUser;
          "listen.group" = icfg.httpdGroup;
          "php_admin_value[open_basedir]" = builtins.concatStringsSep ":" ([icfg.app icfg.varDir] ++ icfg.phpWatchFiles ++ icfg.phpOpenbasedir);
        }
        // optionalAttrs (icfg.phpSession) { "php_admin_value[session.save_path]" = "${icfg.varDir}/phpSessions"; }
        // icfg.phpPool;
        phpOptions = config.services.phpfpm.phpOptions + icfg.phpOptions;
        inherit (icfg) phpEnv;
      }
    ) cfg.apps;

    services.websites.webappDirs = attrsets.mapAttrs' (name: icfg: attrsets.nameValuePair
      (if icfg.webappName == null then name else icfg.webappName) icfg.webRoot
    ) (attrsets.filterAttrs (n: v: !isNull v.webRoot) cfg.apps);

    services.filesWatcher = attrsets.mapAttrs' (name: icfg: attrsets.nameValuePair
      "phpfpm-${name}" {
        restart = true;
        paths = icfg.phpWatchFiles;
      }
    ) (attrsets.filterAttrs (n: v: builtins.length v.phpWatchFiles > 0) cfg.apps);

    systemd.services = attrsets.mapAttrs' (name: icfg: attrsets.nameValuePair
      "phpfpm-${name}" {
        after = lib.mkAfter icfg.serviceDeps;
        wants = icfg.serviceDeps;
        preStart = lib.mkAfter (optionalString (!isNull icfg.varDir) ''
          watchFilesChanged() {
            ${optionalString (builtins.length icfg.phpWatchFiles == 0) "return 1"}
            [ ! -f "${icfg.varDir}"/watchedFiles ] \
              || ! sha512sum -c --status ${icfg.varDir}/watchedFiles
          }
          appDirChanged() {
            [ ! -f "${icfg.varDir}/currentWebappDir" -o \
              "${icfg.app}" != "$(cat ${icfg.varDir}/currentWebappDir 2>/dev/null)" ]
          }
          updateWatchFiles() {
            ${optionalString (builtins.length icfg.phpWatchFiles == 0) "return 0"}
            sha512sum ${builtins.concatStringsSep " " icfg.phpWatchFiles} > ${icfg.varDir}/watchedFiles
          }

          if watchFilesChanged || appDirChanged; then
            pushd ${icfg.app} > /dev/null
            ${builtins.concatStringsSep "\n  " (map (c: "/run/wrappers/bin/sudo -u ${icfg.httpdUser} ${c}") icfg.preStartActions) }
            popd > /dev/null
            echo -n "${icfg.app}" > ${icfg.varDir}/currentWebappDir
            updateWatchFiles
          fi
        '');
      }
    ) cfg.apps;

    system.activationScripts = attrsets.mapAttrs' (name: icfg: attrsets.nameValuePair
      name {
        deps = [];
        text = optionalString (!isNull icfg.varDir) ''
          install -m ${icfg.mode} -o ${icfg.httpdUser} -g ${icfg.httpdGroup} -d ${icfg.varDir}
          '' + optionalString (icfg.phpSession) ''
          install -m 0700 -o ${icfg.httpdUser} -g ${icfg.httpdGroup} -d ${icfg.varDir}/phpSessions
          '' + builtins.concatStringsSep "\n" (attrsets.mapAttrsToList (n: v: ''
            install -m ${v} -o ${icfg.httpdUser} -g ${icfg.httpdGroup} -d ${icfg.varDir}/${n}
            '') icfg.varDirPaths);
      }
    ) cfg.apps;
  };
}
