{ config, ... }:
{
  sops.secrets = {
    ntfy_topic = {
      sopsFile = ../../../secrets/secrets.yaml;
      key = "ntfy_topic";
    };
    riddlebot_env = {
      sopsFile = ../../../secrets/riddlebot.env;
      format = "dotenv";
    };
  };

  homelab = {
    enable = true;
    baseDomainName = "avyay.in";

    motd.enable = true;
    notifications.ntfySecretsFile = config.sops.secrets.ntfy_topic.path;

    services = {
      enable = false;

      slackbots.riddlebot = {
        enable = true;
        secretsFile = config.sops.secrets.riddlebot_env.path;
      };
    };
  };
}
