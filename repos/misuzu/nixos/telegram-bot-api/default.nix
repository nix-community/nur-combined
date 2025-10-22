{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.telegram-bot-api;
in
{
  options.services.telegram-bot-api = {
    enable = lib.mkEnableOption "telegram-bot-api";
    package = lib.mkPackageOption pkgs "telegram-bot-api" { };
    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Environment file for specifying secrets.

        You probably want to set `TELEGRAM_API_ID` and `TELEGRAM_API_HASH`.
        See https://github.com/tdlib/telegram-bot-api?tab=readme-ov-file#usage
      '';
    };
    settings = lib.mkOption {
      type = lib.types.submodule {
        freeformType =
          with lib.types;
          oneOf [
            bool
            int
            str
          ];
        options = {
          local = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = ''
              Allow the Bot API server to serve local requests.
            '';
          };
          api-id = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = ''
              Application identifier for Telegram API access,
              which can be obtained at https://my.telegram.org
              (defaults to the value of the TELEGRAM_API_ID environment variable).
            '';
          };
          api-hash = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = ''
              Application identifier hash for Telegram API access,
              which can be obtained at https://my.telegram.org
              (defaults to the value of the TELEGRAM_API_HASH environment variable).
            '';
          };
          http-port = lib.mkOption {
            type = lib.types.int;
            default = 8081;
            description = ''
              HTTP listening port.
            '';
          };
          http-stat-port = lib.mkOption {
            type = lib.types.nullOr lib.types.int;
            default = null;
            description = ''
              HTTP statistics port.
            '';
          };
          http-ip-address = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = ''
              Local IP address, HTTP connections to which will be accepted.
              By default, connections to any local IPv4 address are accepted.
            '';
          };
          http-stat-ip-address = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = ''
              Local IP address, HTTP statistics connections to which will be accepted.
              By default, statistics connections to any local IPv4 address are accepted.
            '';
          };
        };
      };
      default = { };
      description = ''
        Use `telegram-bot-api --help` to receive the list of all available
        options of the Telegram Bot API server.
      '';
    };
    group = lib.mkOption {
      type = lib.types.str;
      description = "Group account under which telegram-bot-api runs.";
    };
    user = lib.mkOption {
      type = lib.types.str;
      description = "User account under which telegram-bot-api runs.";
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.services.telegram-bot-api = {
      description = "Telegram Bot API server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;
        ExecStart = "${lib.getExe cfg.package} ${
          lib.cli.toGNUCommandLineShell { optionValueSeparator = "="; } cfg.settings
        }";
        Restart = "on-failure";
        RestartSec = "5s";
        StateDirectory = "telegram-bot-api";
        WorkingDirectory = "/var/lib/telegram-bot-api";
        Group = cfg.group;
        User = cfg.user;
      };
    };
  };
}
