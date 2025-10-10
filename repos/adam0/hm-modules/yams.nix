{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.services.yams;
in
{
  options.services.yams = {
    enable = mkEnableOption "yams Last.FM scrobbler for MPD";

    package = mkOption {
      type = types.package;
      default = pkgs.yams;
      defaultText = literalExpression "pkgs.yams";
      description = "The yams package to use.";
    };

    settings = {
      mpd = {
        host = mkOption {
          type = types.str;
          default = "127.0.0.1";
          description = "MPD host to connect to.";
        };

        port = mkOption {
          type = types.port;
          default = 6600;
          description = "MPD port to connect to.";
        };
      };

      scrobbling = {
        threshold = mkOption {
          type = types.ints.between 1 100;
          default = 50;
          description = "The minimum percentage of a track that must be played before scrobbling.";
        };

        realTime = mkOption {
          type = types.bool;
          default = true;
          description = "Use real times when calculating scrobble times (how long you've been running the app, not the track time reported by MPD).";
        };

        allowDuplicates = mkOption {
          type = types.bool;
          default = false;
          description = "Allow the program to scrobble the same track multiple times in a row.";
        };
      };

      keepAlive = mkOption {
        type = types.bool;
        default = false;
        description = "If true, will not exit on initial MPD connection failure and will always attempt to reconnect.";
      };

      debug = mkOption {
        type = types.bool;
        default = false;
        description = "Run in debug mode with verbose logging.";
      };
    };

    extraArgs = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Additional command-line arguments to pass to yams.";
      example = [ "--disable-log" ];
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    systemd.user.services.yams = mkIf pkgs.stdenv.hostPlatform.isLinux {
      Unit = {
        Description = "yams - Yet Another MPD Scrobbler";
        After = [ "mpd.service" ];
      };

      Service = {
        Type = "simple";
        Environment = [
          "NON_INTERACTIVE=1"
          "MPD_HOST=${cfg.settings.mpd.host}"
          "MPD_PORT=${toString cfg.settings.mpd.port}"
        ];
        ExecStart =
          let
            args = [
              (getExe cfg.package)
              "-N"
            ]
            ++ optional (cfg.settings.scrobbling.threshold != null) [
              "-t"
              (toString cfg.settings.scrobbling.threshold)
            ]
            ++ optional cfg.settings.scrobbling.realTime "-r"
            ++ optional cfg.settings.scrobbling.allowDuplicates "-d"
            ++ optional cfg.settings.keepAlive "--keep-alive"
            ++ optional cfg.settings.debug "-D"
            ++ cfg.extraArgs;
          in
          escapeShellArgs args;
        Restart = "on-failure";
        RestartSec = 10;
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    launchd.agents.yams = mkIf pkgs.stdenv.hostPlatform.isDarwin {
      enable = true;
      config = {
        ProgramArguments =
          let
            args = [
              (getExe cfg.package)
              "-N"
            ]
            ++ optional (cfg.settings.scrobbling.threshold != null) "-t"
            ++ optional (cfg.settings.scrobbling.threshold != null) (toString cfg.settings.scrobbling.threshold)
            ++ optional cfg.settings.scrobbling.realTime "-r"
            ++ optional cfg.settings.scrobbling.allowDuplicates "-d"
            ++ optional cfg.settings.keepAlive "--keep-alive"
            ++ optional cfg.settings.debug "-D"
            ++ cfg.extraArgs;
          in
          args;
        KeepAlive = true;
        ProcessType = "Interactive";
        EnvironmentVariables = {
          NON_INTERACTIVE = "1";
          MPD_HOST = cfg.settings.mpd.host;
          MPD_PORT = toString cfg.settings.mpd.port;
        };
      };
    };
  };
}
