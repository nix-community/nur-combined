{ pkgs, config, lib, ... }:

let
  cfg = config.services.commit-notifier;
in
{
  options.services.commit-notifier = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to enable commit-notifier service.
      '';
    };
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.nur.repos.linyinfeng.commit-notifier;
      defaultText = "pkgs.nur.repos.linyinfeng.commit-notifier";
      description = ''
        commit-notifier derivation to use.
      '';
    };
    cron = lib.mkOption {
      type = lib.types.str;
      description = ''
        Update cron expression.
      '';
    };
    tokenFiles = {
      telegramBot  = lib.mkOption {
        type = lib.types.str;
        description = ''
          Telegram bot token file.
        '';
      };
      github  = lib.mkOption {
        type = lib.types.str;
        description = ''
          GitHub token file.
        '';
      };
    };
    rustLog = lib.mkOption {
      type = lib.types.str;
      default = "info";
      description = ''
        RUST_LOG environment variable;
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.commit-notifier = {
      description = "Git commit notifier";

      script = ''
        export TELOXIDE_TOKEN=$(cat "$CREDENTIALS_DIRECTORY/telegram-bot")
        export GITHUB_TOKEN=$(cat "$CREDENTIALS_DIRECTORY/github")

        "${cfg.package}/bin/commit-notifier" \
          --working-dir /var/lib/commit-notifier \
          --cron "${cfg.cron}"
      '';

      path = [
        pkgs.git
      ];

      serviceConfig = {
        DynamicUser = true;
        StateDirectory = "commit-notifier";
        LoadCredential = [
          "telegram-bot:${cfg.tokenFiles.telegramBot}"
          "github:${cfg.tokenFiles.github}"
        ];
      };

      environment."RUST_LOG" = cfg.rustLog;

      wantedBy = [ "multi-user.target" ];
    };
  };
}
