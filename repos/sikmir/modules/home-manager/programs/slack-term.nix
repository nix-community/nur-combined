{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.programs.slack-term;
in
{
  meta.maintainers = [ maintainers.sikmir ];

  options.programs.slack-term = {
    enable = mkEnableOption "Slack client for your terminal";

    package = mkOption {
      default = pkgs.slack-term;
      defaultText = literalExpression "pkgs.slack-term";
      description = "slack-term package to install.";
      type = types.package;
    };

    token = mkOption {
      description = "Slack token.";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    home.file.".slack-term".text = ''
      {
        "slack_token": "${cfg.token}",
        "sidebar_width": 2,
        "notify": "mention",
        "emoji": true,
        "theme": {
          "message": {
            "time_format": "02/01 15:04",
            "time": "fg-green,fg-bold",
            "name": "colorize,fg-bold",
            "text": "fg-white"
          },
          "channel": {
            "prefix": "fg-red,fg-bold",
            "icon": "fg-green,fg-bold",
            "text": "fg-blue,fg-bold"
          }
        }
      }
    '';
  };
}
