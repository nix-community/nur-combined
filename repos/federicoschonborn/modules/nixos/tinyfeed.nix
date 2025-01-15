{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.services.tinyfeed;

  defaultUser = "tinyfeed";
in

{
  options.services.tinyfeed = {
    enable = lib.mkEnableOption "tinyfeed";

    package = lib.mkPackageOption pkgs "tinyfeed" { };

    user = lib.mkOption {
      type = lib.types.str;
      default = defaultUser;
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = defaultUser;
    };

    homeDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/tinyfeed";
    };

    feeds = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "https://nixos.org/blog/announcements-rss.xml"
      ];
    };

    description = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };

    interval = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = null;
    };

    limit = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = null;
    };

    name = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };

    quiet = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    requests = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = null;
    };

    stylesheet = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
    };

    template = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
    };

    timeout = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = null;
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {
    users.users = lib.mkIf (cfg.user == defaultUser) {
      ${defaultUser} = {
        isSystemUser = true;
        group = defaultUser;
        home = cfg.homeDir;
        createHome = true;
      };
    };

    users.groups = lib.mkIf (cfg.group == defaultUser) {
      ${defaultUser} = { };
    };

    systemd.services.tinyfeed = {
      description = "tinyfeed";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = lib.escapeShellArgs (
          [
            (lib.getExe cfg.package)
            "--daemon"
            "--input"
            (pkgs.writeText "feeds.txt" (lib.concatLines cfg.feeds))
          ]
          ++ lib.optionals (cfg.description != null) [
            "--description"
            cfg.description
          ]
          ++ lib.optionals (cfg.interval != null) [
            "--interval"
            cfg.interval
          ]
          ++ lib.optionals (cfg.limit != null) [
            "--limit"
            cfg.limit
          ]
          ++ lib.optionals (cfg.name != null) [
            "--name"
            cfg.name
          ]
          ++ lib.optional cfg.quiet "--quiet"
          ++ lib.optionals (cfg.requests != null) [
            "--requests"
            cfg.requests
          ]
          ++ lib.optionals (cfg.stylesheet != null) [
            "--stylesheet"
            cfg.stylesheet
          ]
          ++ lib.optionals (cfg.template != null) [
            "--template"
            cfg.template
          ]
          ++ lib.optionals (cfg.timeout != null) [
            "--timeout"
            cfg.timeout
          ]
          ++ cfg.extraArgs
        );
        User = cfg.user;
        Group = cfg.group;
        StateDirectory = builtins.baseNameOf cfg.homeDir;
        WorkingDirectory = cfg.homeDir;
      };
    };
  };

  meta.maintainers = [ lib.maintainers.federicoschonborn ];
}
