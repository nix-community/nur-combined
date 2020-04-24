{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.naemon;

  naemonConfig = pkgs.runCommand "naemon-config" {
    objectsFile = pkgs.writeText "naemon_objects.cfg" cfg.objectDefs;
    resourceFile = config.secrets.fullPaths."naemon/resources.cfg";
    extraConfig = pkgs.writeText "extra.cfg" cfg.extraConfig;
    inherit (cfg) logDir varDir runDir cacheDir;
  } ''
     substituteAll ${./naemon.cfg} $out
     cat $extraConfig >> $out
    '';
in
{
  options = {
    services.naemon = {
      enable = mkOption {
        default = false;
        description = "
          Whether to use <link
          xlink:href='http://www.naemon.org/'>Naemon</link> to monitor
          your system or network.
        ";
      };

      objectDefs = mkOption {
        type = types.lines;
        default = "";
        description = "
          A list of Naemon object configuration that must define
          the hosts, host groups, services and contacts for the
          network that you want Naemon to monitor.
        ";
      };

      extraResource = mkOption {
        type = types.lines;
        default = "";
        example = ''
            # Sets $USER2$ to be the path to event handlers
            #$USER2$=/usr/lib/monitoring-plugins/eventhandlers

            # Store some usernames and passwords (hidden from the CGIs)
            #$USER3$=someuser
            #$USER4$=somepassword
          '';
        description = "
          Lines to add to the resource file
            # You can define $USERx$ macros in this file, which can in turn be used
            # in command definitions in your host config file(s).  $USERx$ macros are
            # useful for storing sensitive information such as usernames, passwords,
            # etc.  They are also handy for specifying the path to plugins and
            # event handlers - if you decide to move the plugins or event handlers to
            # a different directory in the future, you can just update one or two
            # $USERx$ macros, instead of modifying a lot of command definitions.
            #
            # Naemon supports up to 256 $USERx$ macros ($USER1$ through $USER256$)
            #
            # Resource files may also be used to store configuration directives for
            # external data sources like MySQL...
            #
        ";
      };

      extraConfig = mkOption {
        type = types.lines;
        default = "";
        description = "
          Extra config to append to main config
        ";
      };

      user = mkOption {
        type = types.str;
        default = "naemon";
        description = "User for naemon";
      };

      group = mkOption {
        type = types.str;
        default = "naemon";
        description = "Group for naemon";
      };

      varDir = mkOption {
        type = types.path;
        default = "/var/lib/naemon";
        description = "The directory where naemon stores its data";
      };

      cacheDir = mkOption {
        type = types.path;
        default = "/var/cache/naemon";
        description = "The directory where naemon stores its cache";
      };

      runDir = mkOption {
        type = types.path;
        default = "/run/naemon";
        description = "The directory where naemon stores its runtime files";
      };

      logDir = mkOption {
        type = types.path;
        default = "/var/log/naemon";
        description = "The directory where naemon stores its log files";
      };

      package = mkOption {
        type = types.package;
        default = pkgs.naemon.override {
          inherit (cfg) varDir cacheDir logDir runDir user group;
        };
        description  = ''
          Naemon package to use
          '';
      };
    };
  };


  config = mkIf cfg.enable {
    secrets.keys = [
      {
        dest = "naemon/resources.cfg";
        user = cfg.user;
        group = cfg.group;
        permissions = "0400";
        text = ''
          $USER1$=${pkgs.monitoring-plugins}/libexec
          ${cfg.extraResource}
          '';
      }
    ];

    users.users = optionalAttrs (cfg.user == "naemon") {
      naemon = {
        group = cfg.group;
        uid   = config.ids.uids.nagios;
        extraGroups = [ "keys" ];
      };
    };
    users.groups = optionalAttrs (cfg.user == "naemon") {
      naemon = {
        gid = config.ids.gids.nagios;
      };
    };

    services.filesWatcher.naemon = {
      paths = [ config.secrets.fullPaths."naemon/resources.cfg" ];
    };
    systemd.services.naemon = {
      description = "Naemon monitoring daemon";
      path     = [ cfg.package pkgs.monitoring-plugins ];
      wantedBy = [ "multi-user.target" ];
      after    = [ "network.target" ];

      preStart = "${cfg.package}/bin/naemon -vp ${naemonConfig}";
      script = "${cfg.package}/bin/naemon --daemon ${naemonConfig}";
      reload = "${pkgs.utillinux}/bin/kill -HUP $MAINPID";
      serviceConfig = {
        User = cfg.user;
        Restart = "always";
        RestartSec = 2;
        StandardOutput = "journal";
        StandardError = "inherit";
        PIDFile = "${cfg.runDir}/naemon.pid";
        LogsDirectory = assert lib.strings.hasPrefix "/var/log/" cfg.logDir;
          lib.strings.removePrefix "/var/log/" cfg.logDir;
        CacheDirectory = assert lib.strings.hasPrefix "/var/cache/" cfg.cacheDir;
          let unprefixed = lib.strings.removePrefix "/var/cache/" cfg.cacheDir;
          in [ unprefixed "${unprefixed}/checkresults" ];
        StateDirectory = assert lib.strings.hasPrefix "/var/lib/" cfg.varDir;
          lib.strings.removePrefix "/var/lib/" cfg.varDir;
        RuntimeDirectory = assert lib.strings.hasPrefix "/run/" cfg.runDir;
          lib.strings.removePrefix "/run/" cfg.runDir;
      };
    };
  };
}
