{ lib, pkgs, config, ... }:
let
  name = "etherpad-lite";
  cfg = config.services.etherpad-lite;

  uid = config.ids.uids.etherpad-lite;
  gid = config.ids.gids.etherpad-lite;
in
{
  options.services.etherpad-lite = {
    enable = lib.mkEnableOption "Enable Etherpad lite’s service";
    user = lib.mkOption {
      type = lib.types.str;
      default = name;
      description = "User account under which Etherpad lite runs";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = name;
      description = "Group under which Etherpad lite runs";
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/${name}";
      description = ''
        The directory where Etherpad lite stores its data.
      '';
    };
    socketsDir = lib.mkOption {
      type = lib.types.path;
      default = "/run/${name}";
      description = ''
        The directory where Etherpad lite stores its sockets.
      '';
    };
    configFile = lib.mkOption {
      type = lib.types.path;
      description = ''
        The config file path for Etherpad lite.
        '';
    };
    sessionKeyFile = lib.mkOption {
      type = lib.types.path;
      description = ''
        The Session key file path for Etherpad lite.
        '';
    };
    apiKeyFile = lib.mkOption {
      type = lib.types.path;
      description = ''
        The API key file path for Etherpad lite.
        '';
    };
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.webapps.etherpad-lite;
      description = ''
        Etherpad lite package to use.
        '';
    };
    modules = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = ''
        Etherpad lite modules to use.
        '';
    };
    # Output variables
    workdir = lib.mkOption {
      type = lib.types.package;
      default = cfg.package.withModules cfg.modules;
      description = ''
      Adjusted Etherpad lite package with plugins
      '';
      readOnly = true;
    };
    systemdStateDirectory = lib.mkOption {
      type = lib.types.str;
      # Use ReadWritePaths= instead if varDir is outside of /var/lib
      default = assert lib.strings.hasPrefix "/var/lib/" cfg.dataDir;
        lib.strings.removePrefix "/var/lib/" cfg.dataDir;
      description = ''
      Adjusted Etherpad lite data directory for systemd
      '';
      readOnly = true;
    };
    systemdRuntimeDirectory = lib.mkOption {
      type = lib.types.str;
      # Use ReadWritePaths= instead if socketsDir is outside of /run
      default = assert lib.strings.hasPrefix "/run/" cfg.socketsDir;
        lib.strings.removePrefix "/run/" cfg.socketsDir;
      description = ''
      Adjusted Etherpad lite sockets directory for systemd
      '';
      readOnly = true;
    };
    sockets = lib.mkOption {
      type = lib.types.attrsOf lib.types.path;
      default = {
        node  = "${cfg.socketsDir}/etherpad-lite.sock";
      };
      readOnly = true;
      description = ''
        Etherpad lite sockets
        '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.etherpad-lite = {
      description = "Etherpad-lite";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "postgresql.service" ];
      wants = [ "postgresql.service" ];

      environment.NODE_ENV = "production";
      environment.HOME = cfg.workdir;

      path = [ pkgs.nodejs ];

      script = ''
        exec ${pkgs.nodejs}/bin/node ${cfg.workdir}/src/node/server.js \
          --sessionkey ${cfg.sessionKeyFile} \
          --apikey ${cfg.apiKeyFile} \
          --settings ${cfg.configFile}
      '';

      postStart = ''
        while [ ! -S ${cfg.sockets.node} ]; do
          sleep 0.5
        done
        chmod a+w ${cfg.sockets.node}
        '';
      serviceConfig = {
        DynamicUser = true;
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.workdir;
        PrivateTmp = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        ProtectHome = true;
        ProtectControlGroups = true;
        ProtectKernelModules = true;
        Restart = "always";
        Type = "simple";
        TimeoutSec = 60;
        RuntimeDirectory = cfg.systemdRuntimeDirectory;
        StateDirectory= cfg.systemdStateDirectory;
        ExecStartPre = [
          "+${pkgs.coreutils}/bin/install -d -m 0755 -o ${cfg.user} -g ${cfg.group} ${cfg.dataDir}/ep_initialized"
          "+${pkgs.coreutils}/bin/chown -R ${cfg.user}:${cfg.group} ${cfg.dataDir} ${cfg.configFile} ${cfg.sessionKeyFile} ${cfg.apiKeyFile}"
        ];
      };
    };

  };
}
