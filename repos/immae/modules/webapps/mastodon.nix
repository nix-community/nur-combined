{ lib, pkgs, config, ... }:
let
  name = "mastodon";
  cfg = config.services.mastodon;

  uid = config.ids.uids.mastodon;
  gid = config.ids.gids.mastodon;
in
{
  options.services.mastodon = {
    enable = lib.mkEnableOption "Enable Mastodon’s service";
    user = lib.mkOption {
      type = lib.types.str;
      default = name;
      description = "User account under which Mastodon runs";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = name;
      description = "Group under which Mastodon runs";
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/${name}";
      description = ''
        The directory where Mastodon stores its data.
      '';
    };
    socketsPrefix = lib.mkOption {
      type = lib.types.str;
      default = "live";
      description = ''
        The prefix to use for Mastodon sockets.
        '';
    };
    socketsDir = lib.mkOption {
      type = lib.types.path;
      default = "/run/${name}";
      description = ''
        The directory where Mastodon puts runtime files and sockets.
        '';
    };
    configFile = lib.mkOption {
      type = lib.types.path;
      description = ''
        The configuration file path for Mastodon.
        '';
    };
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.webapps.mastodon;
      description = ''
        Mastodon package to use.
        '';
    };
    # Output variables
    workdir = lib.mkOption {
      type = lib.types.package;
      default = cfg.package.override { varDir = cfg.dataDir; };
      description = ''
      Adjusted mastodon package with overriden varDir
      '';
      readOnly = true;
    };
    systemdStateDirectory = lib.mkOption {
      type = lib.types.str;
      # Use ReadWritePaths= instead if varDir is outside of /var/lib
      default = assert lib.strings.hasPrefix "/var/lib/" cfg.dataDir;
        lib.strings.removePrefix "/var/lib/" cfg.dataDir;
      description = ''
      Adjusted Mastodon data directory for systemd
      '';
      readOnly = true;
    };
    systemdRuntimeDirectory = lib.mkOption {
      type = lib.types.str;
      # Use ReadWritePaths= instead if socketsDir is outside of /run
      default = assert lib.strings.hasPrefix "/run/" cfg.socketsDir;
        lib.strings.removePrefix "/run/" cfg.socketsDir;
      description = ''
      Adjusted Mastodon sockets directory for systemd
      '';
      readOnly = true;
    };
    sockets = lib.mkOption {
      type = lib.types.attrsOf lib.types.path;
      default = {
        node  = "${cfg.socketsDir}/${cfg.socketsPrefix}_node.sock";
        rails = "${cfg.socketsDir}/${cfg.socketsPrefix}_puma.sock";
      };
      readOnly = true;
      description = ''
        Mastodon sockets
        '';
    };
  };

  config = lib.mkIf cfg.enable {
    users.users = lib.optionalAttrs (cfg.user == name) {
      "${name}" = {
        inherit uid;
        group = cfg.group;
        description = "Mastodon user";
        home = cfg.dataDir;
        useDefaultShell = true;
      };
    };
    users.groups = lib.optionalAttrs (cfg.group == name) {
      "${name}" = {
        inherit gid;
      };
    };

    systemd.services.mastodon-streaming = {
      description = "Mastodon Streaming";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "mastodon-web.service" ];

      environment.NODE_ENV = "production";
      environment.SOCKET = cfg.sockets.node;

      path = [ pkgs.nodejs pkgs.bashInteractive ];

      script = ''
        exec npm run start
      '';

      postStart = ''
        while [ ! -S $SOCKET ]; do
          sleep 0.5
        done
        chmod a+w $SOCKET
      '';

      postStop = ''
        rm $SOCKET
      '';

      serviceConfig = {
        User = cfg.user;
        EnvironmentFile = cfg.configFile;
        PrivateTmp = true;
        Restart = "always";
        TimeoutSec = 15;
        Type = "simple";
        WorkingDirectory = cfg.workdir;
        StateDirectory = cfg.systemdStateDirectory;
        RuntimeDirectory = cfg.systemdRuntimeDirectory;
        RuntimeDirectoryPreserve = "yes";
      };

      unitConfig.RequiresMountsFor = cfg.dataDir;
    };

    systemd.services.mastodon-web = {
      description = "Mastodon Web app";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      environment.RAILS_ENV = "production";
      environment.BUNDLE_PATH = "${cfg.workdir.gems}/${cfg.workdir.gems.ruby.gemPath}";
      environment.BUNDLE_GEMFILE = "${cfg.workdir.gems.confFiles}/Gemfile";
      environment.SOCKET = cfg.sockets.rails;

      path = [ cfg.workdir.gems cfg.workdir.gems.ruby pkgs.file ];

      preStart = ''
        install -m 0755 -d ${cfg.dataDir}/tmp/cache
        ./bin/bundle exec rails db:migrate
      '';

      script = ''
        exec ./bin/bundle exec puma -C config/puma.rb
      '';

      postStart = ''
        exec ./bin/tootctl cache clear
        '';
      serviceConfig = {
        User = cfg.user;
        EnvironmentFile = cfg.configFile;
        PrivateTmp = true;
        Restart = "always";
        TimeoutSec = 60;
        Type = "simple";
        WorkingDirectory = cfg.workdir;
        StateDirectory = cfg.systemdStateDirectory;
        RuntimeDirectory = cfg.systemdRuntimeDirectory;
        RuntimeDirectoryPreserve = "yes";
      };

      unitConfig.RequiresMountsFor = cfg.dataDir;
    };

    systemd.services.mastodon-cleanup = {
      description = "Cleanup mastodon";
      startAt = "daily";
      restartIfChanged = false;

      environment.RAILS_ENV = "production";
      environment.BUNDLE_PATH = "${cfg.workdir.gems}/${cfg.workdir.gems.ruby.gemPath}";
      environment.BUNDLE_GEMFILE = "${cfg.workdir.gems.confFiles}/Gemfile";
      environment.SOCKET = cfg.sockets.rails;

      path = [ cfg.workdir.gems cfg.workdir.gems.ruby pkgs.file ];

      script = ''
        exec ./bin/tootctl media remove --days 30
      '';

      serviceConfig = {
        User = cfg.user;
        EnvironmentFile = cfg.configFile;
        PrivateTmp = true;
        Type = "oneshot";
        WorkingDirectory = cfg.workdir;
        StateDirectory = cfg.systemdStateDirectory;
        RuntimeDirectory = cfg.systemdRuntimeDirectory;
        RuntimeDirectoryPreserve = "yes";
      };

      unitConfig.RequiresMountsFor = cfg.dataDir;
    };

    systemd.services.mastodon-sidekiq = {
      description = "Mastodon Sidekiq";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "mastodon-web.service" ];

      environment.RAILS_ENV="production";
      environment.BUNDLE_PATH = "${cfg.workdir.gems}/${cfg.workdir.gems.ruby.gemPath}";
      environment.BUNDLE_GEMFILE = "${cfg.workdir.gems.confFiles}/Gemfile";
      environment.DB_POOL="5";

      path = [ cfg.workdir.gems cfg.workdir.gems.ruby pkgs.imagemagick pkgs.ffmpeg pkgs.file ];

      script = ''
        exec ./bin/bundle exec sidekiq -c 5 -q default -q mailers -q pull -q push
      '';

      serviceConfig = {
        User = cfg.user;
        EnvironmentFile = cfg.configFile;
        PrivateTmp = true;
        Restart = "always";
        TimeoutSec = 15;
        Type = "simple";
        WorkingDirectory = cfg.workdir;
        StateDirectory = cfg.systemdStateDirectory;
        RuntimeDirectory = cfg.systemdRuntimeDirectory;
        RuntimeDirectoryPreserve = "yes";
      };

      unitConfig.RequiresMountsFor = cfg.dataDir;
    };

  };
}
