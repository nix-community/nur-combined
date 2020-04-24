{ lib, pkgs, config, ... }:
let
  name = "diaspora";
  cfg = config.services.diaspora;

  uid = config.ids.uids.diaspora;
  gid = config.ids.gids.diaspora;
in
{
  options.services.diaspora = {
    enable = lib.mkEnableOption "Enable Diaspora’s service";
    user = lib.mkOption {
      type = lib.types.str;
      default = name;
      description = "User account under which Diaspora runs";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = name;
      description = "Group under which Diaspora runs";
    };
    adminEmail = lib.mkOption {
      type = lib.types.str;
      example = "admin@example.com";
      description = "Admin e-mail for Diaspora";
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/${name}";
      description = ''
        The directory where Diaspora stores its data.
      '';
    };
    socketsDir = lib.mkOption {
      type = lib.types.path;
      default = "/run/${name}";
      description = ''
        The directory where Diaspora puts runtime files and sockets.
        '';
    };
    configDir = lib.mkOption {
      type = lib.types.path;
      description = ''
        The configuration path for Diaspora.
        '';
    };
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.webapps.diaspora;
      description = ''
        Diaspora package to use.
        '';
    };
    # Output variables
    systemdStateDirectory = lib.mkOption {
      type = lib.types.str;
      # Use ReadWritePaths= instead if varDir is outside of /var/lib
      default = assert lib.strings.hasPrefix "/var/lib/" cfg.dataDir;
        lib.strings.removePrefix "/var/lib/" cfg.dataDir;
      description = ''
      Adjusted Diaspora data directory for systemd
      '';
      readOnly = true;
    };
    systemdRuntimeDirectory = lib.mkOption {
      type = lib.types.str;
      # Use ReadWritePaths= instead if socketsDir is outside of /run
      default = assert lib.strings.hasPrefix "/run/" cfg.socketsDir;
        lib.strings.removePrefix "/run/" cfg.socketsDir;
      description = ''
      Adjusted Diaspora sockets directory for systemd
      '';
      readOnly = true;
    };
    workdir = lib.mkOption {
      type = lib.types.package;
      default = cfg.package.override {
        varDir = cfg.dataDir;
        podmin_email = cfg.adminEmail;
        config_dir = cfg.configDir;
      };
      description = ''
        Adjusted diaspora package with overriden values
        '';
      readOnly = true;
    };
    sockets = lib.mkOption {
      type = lib.types.attrsOf lib.types.path;
      default = {
        rails = "${cfg.socketsDir}/diaspora.sock";
        eye   = "${cfg.socketsDir}/eye.sock";
      };
      readOnly = true;
      description = ''
        Diaspora sockets
        '';
    };
    pids = lib.mkOption {
      type = lib.types.attrsOf lib.types.path;
      default = {
        eye   = "${cfg.socketsDir}/eye.pid";
      };
      readOnly = true;
      description = ''
        Diaspora pids
        '';
    };
  };

  config = lib.mkIf cfg.enable {
    users.users = lib.optionalAttrs (cfg.user == name) {
      "${name}" = {
        inherit uid;
        group = cfg.group;
        description = "Diaspora user";
        home = cfg.dataDir;
        packages = [ cfg.workdir.gems pkgs.nodejs cfg.workdir.gems.ruby ];
        useDefaultShell = true;
      };
    };
    users.groups = lib.optionalAttrs (cfg.group == name) {
      "${name}" = {
        inherit gid;
      };
    };

    systemd.services.diaspora = {
      description = "Diaspora";
      wantedBy = [ "multi-user.target" ];
      after = [
        "network.target" "redis.service" "postgresql.service"
      ];
      wants = [
        "redis.service" "postgresql.service"
      ];

      environment.RAILS_ENV = "production";
      environment.BUNDLE_PATH = "${cfg.workdir.gems}/${cfg.workdir.gems.ruby.gemPath}";
      environment.BUNDLE_GEMFILE = "${cfg.workdir.gems.confFiles}/Gemfile";
      environment.EYE_SOCK = cfg.sockets.eye;
      environment.EYE_PID = cfg.pids.eye;

      path = [ cfg.workdir.gems pkgs.nodejs cfg.workdir.gems.ruby pkgs.curl pkgs.which pkgs.gawk ];

      preStart = ''
        install -m 0755 -d ${cfg.dataDir}/uploads ${cfg.dataDir}/tmp ${cfg.dataDir}/log
        install -m 0700 -d ${cfg.dataDir}/tmp/pids
        if [ ! -f ${cfg.dataDir}/schedule.yml ]; then
          echo "{}" > ${cfg.dataDir}/schedule.yml
        fi
        ./bin/bundle exec rails db:migrate
      '';

      script = ''
        exec ${cfg.workdir}/script/server
      '';

      serviceConfig = {
        User = cfg.user;
        PrivateTmp = true;
        Restart = "always";
        Type = "simple";
        WorkingDirectory = cfg.workdir;
        StateDirectory = cfg.systemdStateDirectory;
        RuntimeDirectory = cfg.systemdRuntimeDirectory;
        StandardInput = "null";
        KillMode = "control-group";
      };

      unitConfig.RequiresMountsFor = cfg.dataDir;
    };
  };
}
