{ lib, pkgs, config, ... }:
let
  name = "mediagoblin";
  cfg = config.services.mediagoblin;

  uid = config.ids.uids.mediagoblin;
  gid = config.ids.gids.mediagoblin;

  paste_local = pkgs.writeText "paste_local.ini" ''
    [DEFAULT]
    debug = false

    [pipeline:main]
    pipeline = mediagoblin

    [app:mediagoblin]
    use = egg:mediagoblin#app
    config = ${cfg.configFile} ${cfg.workdir}/mediagoblin.ini
    /mgoblin_static = ${cfg.workdir}/mediagoblin/static

    [loggers]
    keys = root

    [handlers]
    keys = console

    [formatters]
    keys = generic

    [logger_root]
    level = INFO
    handlers = console

    [handler_console]
    class = StreamHandler
    args = (sys.stderr,)
    level = NOTSET
    formatter = generic

    [formatter_generic]
    format = %(levelname)-7.7s [%(name)s] %(message)s

    [filter:errors]
    use = egg:mediagoblin#errors
    debug = false

    [server:main]
    use = egg:waitress#main
    unix_socket = ${cfg.sockets.paster}
    unix_socket_perms = 777
    url_scheme = https
    '';
in
{
  options.services.mediagoblin = {
    enable = lib.mkEnableOption "Enable Mediagoblin’s service";
    user = lib.mkOption {
      type = lib.types.str;
      default = name;
      description = "User account under which Mediagoblin runs";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = name;
      description = "Group under which Mediagoblin runs";
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/${name}";
      description = ''
        The directory where Mediagoblin stores its data.
      '';
    };
    socketsDir = lib.mkOption {
      type = lib.types.path;
      default = "/run/${name}";
      description = ''
        The directory where Mediagoblin puts runtime files and sockets.
        '';
    };
    configFile = lib.mkOption {
      type = lib.types.path;
      description = ''
        The configuration file path for Mediagoblin.
        '';
    };
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.webapps.mediagoblin;
      description = ''
        Mediagoblin package to use.
        '';
    };
    plugins = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = ''
        Mediagoblin plugins to use.
        '';
    };
    # Output variables
    workdir = lib.mkOption {
      type = lib.types.package;
      default = cfg.package.withPlugins cfg.plugins;
      description = ''
      Adjusted Mediagoblin package with plugins
      '';
      readOnly = true;
    };
    systemdStateDirectory = lib.mkOption {
      type = lib.types.str;
      # Use ReadWritePaths= instead if varDir is outside of /var/lib
      default = assert lib.strings.hasPrefix "/var/lib/" cfg.dataDir;
        lib.strings.removePrefix "/var/lib/" cfg.dataDir;
      description = ''
      Adjusted Mediagoblin data directory for systemd
      '';
      readOnly = true;
    };
    systemdRuntimeDirectory = lib.mkOption {
      type = lib.types.str;
      # Use ReadWritePaths= instead if socketsDir is outside of /run
      default = assert lib.strings.hasPrefix "/run/" cfg.socketsDir;
        lib.strings.removePrefix "/run/" cfg.socketsDir;
      description = ''
      Adjusted Mediagoblin sockets directory for systemd
      '';
      readOnly = true;
    };
    sockets = lib.mkOption {
      type = lib.types.attrsOf lib.types.path;
      default = {
        paster = "${cfg.socketsDir}/mediagoblin.sock";
      };
      readOnly = true;
      description = ''
        Mediagoblin sockets
        '';
    };
    pids = lib.mkOption {
      type = lib.types.attrsOf lib.types.path;
      default = {
        paster = "${cfg.socketsDir}/mediagoblin.pid";
        celery = "${cfg.socketsDir}/mediagoblin-celeryd.pid";
      };
      readOnly = true;
      description = ''
        Mediagoblin pid files
        '';
    };
  };

  config = lib.mkIf cfg.enable {
    users.users = lib.optionalAttrs (cfg.user == name) {
      "${name}" = {
        inherit uid;
        group = cfg.group;
        description = "Mediagoblin user";
        home = cfg.dataDir;
        useDefaultShell = true;
      };
    };
    users.groups = lib.optionalAttrs (cfg.group == name) {
      "${name}" = {
        inherit gid;
      };
    };

    systemd.services.mediagoblin-web = {
      description = "Mediagoblin service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      wants = [ "postgresql.service" "redis.service" ];

      environment.SCRIPT_NAME = "/mediagoblin/";

      script = ''
        exec ./bin/paster serve \
          ${paste_local} \
          --pid-file=${cfg.pids.paster}
        '';
      preStop = ''
        exec ./bin/paster serve \
          --pid-file=${cfg.pids.paster} \
          ${paste_local} stop
        '';
      preStart = ''
        if [ -d ${cfg.dataDir}/plugin_static/ ]; then
          rm ${cfg.dataDir}/plugin_static/coreplugin_basic_auth
          ln -sf ${cfg.workdir}/mediagoblin/plugins/basic_auth/static ${cfg.dataDir}/plugin_static/coreplugin_basic_auth
        fi
        ./bin/gmg -cf ${cfg.configFile} dbupdate
        '';

      serviceConfig = {
        User = cfg.user;
        PrivateTmp = true;
        Restart = "always";
        TimeoutSec = 15;
        Type = "simple";
        WorkingDirectory = cfg.workdir;
        RuntimeDirectory = cfg.systemdRuntimeDirectory;
        StateDirectory= cfg.systemdStateDirectory;
        PIDFile = cfg.pids.paster;
      };

      unitConfig.RequiresMountsFor = cfg.dataDir;
    };

    systemd.services.mediagoblin-celeryd = {
      description = "Mediagoblin service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "mediagoblin-web.service" ];

      environment.MEDIAGOBLIN_CONFIG = cfg.configFile;
      environment.CELERY_CONFIG_MODULE = "mediagoblin.init.celery.from_celery";

      script = ''
        exec ./bin/celery worker \
          --logfile=${cfg.dataDir}/celery.log \
          --loglevel=INFO
        '';

      serviceConfig = {
        User = cfg.user;
        PrivateTmp = true;
        Restart = "always";
        TimeoutSec = 60;
        Type = "simple";
        WorkingDirectory = cfg.workdir;
        RuntimeDirectory = cfg.systemdRuntimeDirectory;
        StateDirectory= cfg.systemdStateDirectory;
        PIDFile = cfg.pids.celery;
      };

      unitConfig.RequiresMountsFor = cfg.dataDir;
    };
  };
}
